#!/usr/bin/env bash

#__INTERNAL_LOGGING__=true
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

namespace seamless

Log.AddOutput seamless CUSTOM
Log.AddOutput error ERROR
#Log.AddOutput oo/parameters-executing CUSTOM

# ------------------------ #

declare __declaration_type

getDeclaration() {
  local variableName="$1"
  local targetVariable="$2"
  
  local declaration
  local regexArray="declare -([a-zA-Z-]+) $variableName='(.*)'"
  local regex="declare -([a-zA-Z-]+) $variableName=\"(.*)\""
  local definition=$(declare -p $variableName 2> /dev/null || true)
  
  local escaped="'\\\'"
  local escapedQuotes='\\"'
  local singleQuote='"'
  
  if [[ "$definition" =~ $regexArray ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}"
  elif [[ "$definition" =~ $regex ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}"
    declaration="${declaration//$escapedQuotes/$singleQuote}"
  fi
  
  eval $targetVariable=\$declaration
  eval ${targetVariable}_type=\${BASH_REMATCH[1]}
}

printDeclaration() {
  local __declaration
  getDeclaration "$1" __declaration
  echo "$__declaration"
}

capturePipe() {
  read -r -d '' $1 || true
}

capturePipeFaithful() {
  IFS= read -r -d '' $1 || true
}

## note: declaration needs to be trimmed, 
## since bash adds an enter at the end, hence %?
alias @resolve:this="
  local __local_return_self_and_result=false
  [[ \$__return_self_and_result == 'true' ]] && local __local_return_self_and_result=true && local __return_self_and_result=false
  # TODO: local __access_private_members_of=
  if [[ -z \${__use_this_natively+x} ]];
  then
    local __declaration;
    
    if [[ ! -z \"\${useReturnValueDefinition}\" ]];
    then
      DEBUG subject='@resolve:this' Log 'using: ReturnValueDefinition'
      local __declaration_type;
      __declaration=\"\$returnValueDefinition\"
      __declaration_type=\$returnValueType
    elif [[ -z \${thisReference+x} ]]; 
    then
      DEBUG subject='@resolve:this' Log 'using: pipe'
      capturePipe __declaration;
      local __declaration_type=\$(Variable.GetParamFromType \${FUNCNAME[0]%.*})
      # Log capturing via pipe \${__declaration_type}
    else
      DEBUG subject='@resolve:this' Log 'using: thisReference'
      getDeclaration \$thisReference __declaration;
      unset thisReference;
    fi;
    local -\${__declaration_type:--} this=\${__declaration};
    unset __declaration;
    # unset __declaration_type;
  fi
  "

# there could be a variable "modifiedThis", 
# which is set to "printDeclaration this"
# so we kind of have two returns, one real one, 
# and one for the internal change
#
# this way:
# someMap set a 30
#
# would actually update someMap
# and manual rewriting: someMap=$(someMap set a 30)
# would not be required 

@return() {
  local variableName=$1
  
  local __return_declaration
  local __return_declaration_type
  
  ## if not returning anything, just update the self
  if [[ ! -z "$variableName" ]]
  then
    getDeclaration $variableName __return_declaration
  elif [[ ! -z "${monad+x}" ]]
  then
    getDeclaration this __return_declaration
  fi
  
  if [[ "${__local_return_self_and_result}" == "true" || "${__return_self_and_result}" == "true" ]]
  then
    # Log "returning heavy"
    local -a __return=("$(printDeclaration this)" "$__return_declaration" "$__return_declaration_type")
    
    printDeclaration __return
    # __modifiedThis="$(printDeclaration this)"
  elif [[ "${#__return_declaration}" -gt 0 ]]
  then
    echo "$__return_declaration"
  fi
}
alias @get='printDeclaration'

@return:value() {
  local value="$@"
  
  @return value
}

# ------------------------ #

executeMethodOfType() {
  local type="$1"
  local variableName="$2"
  local method="$3"
  
  shift; shift; shift;
  
  thisReference=$variableName $type.$method "$@"
}

# /**
#  * used inside handleType() for getting out the return value and updating this 
#  */
executeStack() {
  DEBUG Log "will execute: $method (${params[@]})"
  
  if [[ ! -z "$returnValueDefinition" && $affectTheInitialVariable == false ]]
  then
    local -$returnValueType "__self=$returnValueDefinition"
    variableName=__self
  fi
  
  # Log "Will assign: result=$(__return_self_and_result=true executeMethodOfType "$type" "$variableName" "$method" "${params[@]}")"
  local resultString=$(__return_self_and_result=true executeMethodOfType "$type" "$variableName" "$method" "${params[@]}")
  
  if [[ -z "$resultString" ]]
  then
    ## TODO: debug these situations
    local -a result=( "$(@get $variableName)" "" "" )
  else
    # Log "wtf $resultString"
    local -a result=$resultString
    # eval "local -a result=$resultString"
  fi
  
  unset __self
  
  # declare -p result
  local assignResult="${result[0]}"
  # declare -p assignResult
  
  local typeParam=$(Variable.GetParamFromType $type)
  
  # Log "Will eval: $variableName=$assignResult"
  if [[ "$typeParam" =~ [aA] ]]
  then
    # update the object
    eval "$variableName=$assignResult"
  else
    eval "$variableName=\"\$assignResult\""
  fi
  
  # update the result
  returnValueDefinition="${result[1]}"
  returnValueType="${result[2]}"
  
  if [[ "$assignResult" != "${returnValueDefinition}" ]]
  then
    affectTheInitialVariable=false
    type=$(Variable.GetTypeFromParam $returnValueType)
  fi
  
  # TODO: this should work directly but doesn't
  # eval $variableName=\$assignResult
}

handleType() {
  local variableName="$1"
  local type=$(Variable.GetType $variableName)
  local affectTheInitialVariable=true
  local -a propertyTree=("$1")
  
  if [[ "$type" == "undefined" ]]
  then
    e="No variable named: $variableName" throw
    return
  fi
  
  shift
  
  local returnValueDefinition
  local returnValueType
  
  if [[ $# -gt 0 ]]
  then
    local method
    local -a params
    local mode=method
    local prevMode
    local prevModeNext
    local treatTheRestAsParams=false
    
    while [[ $# -gt 0 ]]
    do
      prevModeNext=$mode
      if [[ "$1" == '@' ]]
      then
        # mode=method
        treatTheRestAsParams=true
      elif [[ "$1" == '[' || "$1" == '{' ]]
      then
        mode=params
      elif [[ "$1" == '[]' || "$1" == ']' || "$1" == '{}' || "$1" == '}' ]]
      then
        executeStack
        
        method=''
        params=()
        mode=method
        prevModeNext=params
      elif [[ "$mode" == 'params' ]]
      then
        params+=("$1")
      elif [[ "$mode" == 'method' ]]
      then
        # Log $(@get __${type}_property_names | array.indexOf $1) $1 idx
        # Log $(@get __${type}_property_names | array.contains $1 && echo t)
        if Variable::Exists __${type}_property_names && 
            @get __${type}_property_names | array.contains $1
        then
          # stack now belongs to:
          ### selecting property: 
          local property="$1"
          
          # Log found index __${type}_property_names $(@get __${type}_property_names | __return_self_and_result=false array.indexOf $property)
          # Log prop: $property of [$(@get __${type}_property_names)]
          
          ## TODO: teoretically we can get rid of: __return_self_and_result=false
          local -i index=$(@get __${type}_property_names | __return_self_and_result=false array.indexOf $property)
          
          if [[ $index -ge 0 ]]
          then
            DEBUG Log "traversing to a child property $property of type $type"
            
            local newType=__${type}_property_types[$index]
            type=${!newType}
            local typeParam=$(Variable.GetParamFromType $type)
            
            ## TODO: check if this preserves spaces correctly
            local propertyValueIndirect=$variableName[$property]
            
            if [[ -z "${!propertyValueIndirect}" && "$typeParam" =~ [aA] ]]
            then
              local -$typeParam "__$property=()"
            else
              local -$typeParam "__$property=${!propertyValueIndirect}"
            fi
            
            DEBUG Log ".$property new $type value is: " # ${propertyValueIndirect} vs '${!propertyValueIndirect}'
            DEBUG Log "$(declare -p __$property)"
            # affectTheInitialVariable=false
            
            ## TODO: variableName needs to be unique (add count at the end)
            ## in case the same property is nested 
            variableName=__$property
            
            propertyTree+=("$property")
            
            prevModeNext=property
          fi
          ### /selectProperty          
        else
          if [[ "$treatTheRestAsParams" == 'true' ]]
          then
            mode=params
          elif [[ "$prevMode" == 'method' ]]
          then
            executeStack
          fi
          method="$1"
          
        fi
      fi
      prevMode=$prevModeNext
      
      subject="type handling" Log "iter: $1 | prevMode: $prevMode | mode: $mode | type: $type | variable: $variableName | method: $method | #params: ${#params[@]}"
      
      shift
    done
    
    if [[ "$mode" == 'method' && "${#method}" -gt 0 || "$treatTheRestAsParams" == 'true' ]]
    then
      executeStack
    elif [[ "$prevMode" == 'property' ]]
    then
      DEBUG subject='property' Log 'print out the property' $variableName
      ## print out the property
      @get $variableName
    fi
    
    # finally echo the latest return value if not empty
    if [[ ! -z "$returnValueDefinition" ]]
    then
      echo "$returnValueDefinition"
    fi
    
    local -i propertyTreeLength=${#propertyTree[@]}
    if [[ ${#propertyTree[@]} -gt 1 ]]
    then
      # Log PropertyTree: $(@get propertyTree)
      local -a reversedPropertyTree=$(@get propertyTree | __return_self_and_result=false array.reverse)
      
      local -i i=$propertyTreeLength
      local property
      local parent
      for parent in "${reversedPropertyTree[@]}"
      do
        ## recursively insert the children into parents
        
        i+=-1
        (( $i == $propertyTreeLength - 1 )) && property=$parent && continue
        
        local parentVarName=__$parent
        
        (( $i == 0 )) && parentVarName=$parent
        
        local propertyDefinition="$(@get __$property)"
        # Log "Will eval: $parentVarName[$property]=\"\$propertyDefinition\""
        eval "$parentVarName[$property]=\"\$propertyDefinition\""
        
        DEBUG Log "SETTING: ($i) $parentVarName.$property = \"$propertyDefinition\""  
        
        property=$parent
      done
    fi
  else
    @get $variableName
  fi
}

Variable.GetTypeFromParam() {
  local typeInfo="$1"
  
	if [[ "$typeInfo" == "n"* ]]
	then
		echo reference
	elif [[ "$typeInfo" == "a"* ]]
	then
		echo array
	elif [[ "$typeInfo" == "A"* ]]
	then
		echo map
	elif [[ "$typeInfo" == "i"* ]]
	then
		echo integer
	# elif [[ "${!1}" == "$obj:"* ]]
	# then
	# 	echo "$(Object.GetType "${!realObject}")"
	else
		echo string
	fi
}

Variable.GetParamFromType() {
  local typeInfo="$1"
  
	if [[ "$typeInfo" == "reference" ]]
	then
		echo n
	elif [[ "$typeInfo" == "array" ]]
	then
		echo a
	elif [[ "$typeInfo" == "string" ]]
	then
		echo -
	elif [[ "$typeInfo" == "integer" ]]
	then
		echo i
	else
		echo A
	fi
}

Variable.GetType() {
	local typeInfo="$(declare -p $1 2> /dev/null || declare -p | grep "^declare -[aAign\-]* $1\(=\|$\)" || true)"

	if [[ -z "$typeInfo" ]]
	then
		echo undefined
		return 0
	fi

	if [[ "$typeInfo" == "declare -n"* ]]
	then
		echo reference
	elif [[ "$typeInfo" == "declare -a"* ]]
	then
		echo array
	elif [[ "$typeInfo" == "declare -A"* ]]
	then
    local __object_type_ref="$1[__object_type]"
    local __object_type="${!__object_type_ref}"
    if [[ ! -z "${__object_type}" ]]
    then
      echo $__object_type
    else
		  echo map
    fi
	elif [[ "$typeInfo" == "declare -i"* ]]
	then
		echo integer
	# elif [[ "${!1}" == "$obj:"* ]]
	# then
	# 	echo "$(Object.GetType "${!realObject}")"
	else
		echo string
	fi
}

Type.CreateVar() {
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'

    local commandWithArgs=( $1 )
    local command="${commandWithArgs[0]}"

    shift

    if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* ]]
    then
        return 0
    fi

    if [[ "${commandWithArgs[*]}" == "true" ]]
    then
        __typeCreate_next=true
        # Console.WriteStdErr "Will assign next one"
        return 0
    fi

    local varDeclaration="${commandWithArgs[*]:1}"
    if [[ $varDeclaration == '-'* ]]
    then
        varDeclaration="${commandWithArgs[*]:2}"
    fi
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"

    # TODO: make this better:
    if [[ "$varValue" == "$varName" ]]
    then
    	local varValue=""
    fi

    if [[ ! -z $__typeCreate_varType ]]
    then
      # Console.WriteStdErr "SETTING $__typeCreate_varName = \$$__typeCreate_paramNo"
      # Console.WriteStdErr --
      #Console.WriteStdErr $tempName

    	DEBUG Log "creating $__typeCreate_varName ($__typeCreate_varType) = $__typeCreate_varValue"

    	if [[ -z "$__typeCreate_varValue" ]]
      then
        case "$__typeCreate_varType" in
          'array'|'map') eval "$__typeCreate_varName=()" ;;
          'string') eval "$__typeCreate_varName=''" ;;
          'integer') eval "$__typeCreate_varName=0" ;;
          * ) eval "$__typeCreate_varName=([__object_type]=$__typeCreate_varType)" ;;
        esac
      fi
      
      ## declare method with the name of the var ##
      eval "$__typeCreate_varName() {
        handleType $__typeCreate_varName \"\$@\";
      }"

      case "$__typeCreate_varType" in
        'array'|'map'|'string'|'integer') ;;
        *)
          if Function.Exists ${__typeCreate_varType}.constructor
          then
            ${__typeCreate_varName} constructor
          fi
          # local return
          # Object.New $__typeCreate_varType $__typeCreate_varName
          # eval "$__typeCreate_varName=$return"
        ;;
      esac

    	# __oo__objects+=( $__typeCreate_varName )

      unset __typeCreate_varType
      unset __typeCreate_varValue
    fi

    if [[ "$command" != "declare" || "$__typeCreate_next" != "true" ]]
    then
        __typeCreate_normalCodeStarted+=1

        # Console.WriteStdErr "NOPASS ${commandWithArgs[*]}"
        # Console.WriteStdErr "normal code count ($__typeCreate_normalCodeStarted)"
        # Console.WriteStdErr --
    else
        unset __typeCreate_next

        __typeCreate_normalCodeStarted=0
        __typeCreate_varName="$varName"
        __typeCreate_varValue="$varValue"
        __typeCreate_varType="$__capture_type"
        __typeCreate_arrLength="$__capture_arrLength"

        # Console.WriteStdErr "PASS ${commandWithArgs[*]}"
        # Console.WriteStdErr --

        __typeCreate_paramNo+=1
    fi
}

Type.CaptureParams() {
    # Console.WriteStdErr "Capturing Type $_type"
    # Console.WriteStdErr --

    __capture_type="$_type"
}

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias trapAssign='Type.CaptureParams; declare -i __typeCreate_normalCodeStarted=0; trap "declare -i __typeCreate_paramNo; Type.CreateVar \"\$BASH_COMMAND\" \"\$@\"; [[ \$__typeCreate_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __typeCreate_varType && unset __typeCreate_varName && unset __typeCreate_varValue && unset __typeCreate_paramNo" DEBUG; true; true; '
alias reference='_type=reference trapAssign declare -n'
alias string='_type=string trapAssign declare'
alias int='_type=integer trapAssign declare -i'
alias array='_type=array trapAssign declare -a'
alias map='_type=map trapAssign declare -A'
alias global:reference='_type=reference trapAssign declare -ng'
alias global:string='_type=string trapAssign declare -g'
alias global:int='_type=integer trapAssign declare -ig'
alias global:array='_type=array trapAssign declare -ag'
alias global:map='_type=map trapAssign declare -Ag'

# for use in the object's methods
this() {
  handleType this "$@"
}

### MAP 
## TODO: use vars, not $1-9 so references are resolved

map.set() {
  @resolve:this
  
  this["$1"]="$2"
  
  @return #this
}

map.delete() {
  @resolve:this
  
  unset this["$1"]
  
  @return #this
}

map.get() {
  @resolve:this

  @return:value "${this[$1]}"
}

### /MAP

### STRING

string.toUpper() {
  @resolve:this
  
  @return:value "${this^^}"
}

string.=() {
  @resolve:this
  @var value
  
  this="$value"
  
  @return
}

### /STRING

### ARRAY

array.push() {
  @resolve:this
  @var value
  
  # subject=array.push Log $(@get this)
  this+=("$value")
  
  @return
}

array.length() {
  @resolve:this
  
	local value="${#this[@]}"
  @return value
}


array.contains() {
  @resolve:this
  
  local element
  
  @return # is it required?
  
  for element in "${this[@]}"
  do 
    [[ "$element" == "$1" ]] && return 0
  done
  return 1
}

array.indexOf() {
  @resolve:this
  
  # Log this: $(declare -p this)
  
  local index
  
  for index in "${!this[@]}"
  do 
    # Log index: $index "${!this[@]}"
    # Log value: "${this[$index]}"
    [[ "${this[$index]}" == "$1" ]] && @return:value $index && return
  done
  @return:value -1
}

array.reverse() {
  @resolve:this
  
  # Log reversing: $(@get this)
  local -i length=$(this length)
  local -a outArray
  local -i indexFromEnd
  local -i index
  
  for index in "${!this[@]}"
  do
    indexFromEnd=$(( $length - 1 - $index ))
    outArray+=( "${this[$indexFromEnd]}" )
  done
  
  @return outArray
}

### /ARRAY

Variable::Exists() {
  @var variableName
  
  declare -p $variableName &> /dev/null
}

defineProperty() {
  @var visibility
  @var class
  @var type
  @var property
  
  eval "__${class}_property_names+=( $property )"
  eval "__${class}_property_types+=( $type )"
  eval "__${class}_property_visibilities+=( $visibility )"
}

private() {
  # ${FUNCNAME[1]} contains the name of the class
  local class=${FUNCNAME[1]#*:}
  
  defineProperty private $class "$@"
}

public() {
  # ${FUNCNAME[1]} contains the name of the class
  local class=${FUNCNAME[1]#*:}
  
  defineProperty public $class "$@"
}

class:Human() {
  public string firstName
  public string lastName
  public array children
  public Human child
  
  Human.test() {
    @resolve:this
    @return:value "children: $(this children)"
  }
  
  Human.shout() {
    @resolve:this
    
    this firstName = [ "$(this firstName) shout!" ]
    this children push [ 'shout' ]
    local a=$(this test)
    
    @return a
  }
}

initializeClass() {
  @var name
  class:$name
  alias $name="_type=$name trapAssign declare -A"
}

initializeClass Human

# class:Human
# alias Human="_type=Human trapAssign declare -A"

# TODO: required parameters (via named_parameters)
# TODO: special overriden 'echo' and 'printf' function in methods that saves to a variable

function test1() {
  string justDoIt="yes!"
  map ramda=([test]=ho [great]=ok [test]="\$result ''ha'  ha" [enter]=$(printf "\na\nb\n"))
  
  # monad=true ramda set [ "one" "yep" ]
  ramda set [ "one" "yep" ]
  ramda set [ 'two' "oki  dokies" ]
  ramda delete [ enter ]
  ramda delete [ test ]
  ramda
  ramda get [ 'one' ]
  ramda get [ 'one' ] toUpper []
  
  # ramda : get [ 'one' ] | string.toUpper
  # ramda { get 'one' } { toUpper }
  
  ramda set [ 'one' "$(ramda get [ 'one' ] toUpper [])" ]
  ramda
  
  map polio=$(ramda)
  
  map kwiko=$(polio | monad=true map.set "kwiko" "liko")
  kwiko
  map kwiko=$(polio | monad=true map.set "kwiko" "kombo")
  kwiko
  
  justDoIt toUpper
}

# test1

function test2() {
  array hovno
  hovno push [ one ]
  hovno push [ two ]
  hovno
}

# test2 

function test3() {
  map obj=([__object_type]=Human [firstName]=Bazyli)
  declare -p obj
  obj firstName
}

# test3

function test4() {
  Human obj
  obj firstName = [ Ivon ]
  declare -p obj
  obj firstName
}

# test4

function test5() {
  Human obj
  obj children push [ '  "a"  b  c  ' ]
  obj children push [ "123 $(printf "\ntest")" ]
  # declare -p obj
  obj children
}

# test5

function test6() {
  Human obj
  obj child firstName = [ "Ivon \" $(printf "\ntest") 'Ivonova'" ]
  obj child firstName
  # declare -p obj
}

# test6

function test7() {
  Human obj
  obj child child child children push [ '  "a"  b  c  ' ]
  # obj @functional child child child children push '  "a"  b  c  '
  
  # obj { child child child children push 'abc' } { get 'abc' } { toUpper }
  
  test "$(obj child child child children)" == '([0]="  \"a\"  b  c  ")'
  declare -p obj
}

test7

function test8() {
  Human obj
  
  # obj firstName = [ Bazyli ]
  obj @ firstName = Bazyli
  obj shout
  obj shout
  
  declare -p obj
  # obj
}

# test8

## TODO: parametric versions of string/integer/array functions
## they could either take the variable name as param or @array 

## obj firstname = Bazyli
## arr @ push Bazyli
## obj @ firstname = Bazyli