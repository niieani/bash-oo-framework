namespace util/type

import util/bash4
import Array/Contains String/SanitizeForVariable
import util/namedParameters util/pipe util/variable util/command

declare -g __primitive_extension_declaration=2D6A822E
declare -g __primitive_extension_fingerprint__boolean=${__primitive_extension_declaration}36884C70843578D37E6773C4
declare -g __return_separator=52A586A48E074BB6812DCFDC790841F5
declare -g __oo__type_handler_functions=()
declare -g __oo__variableMethodPrefix="$var:"

# /**
#   * Code like: Variable::ExportDeclarationAndTypeToVariables
#   * TODO: Merge parts
#   */
Type::GetTypeOfVariable() {
  local variableName="$1"
  local dereferrence="${2:-true}"

  local regex="declare -([a-zA-Z-]+) $variableName=(.*)"
  local definition=$(declare -p "${variableName}" 2> /dev/null || true)

  [[ -z "$definition" ]] && e="Variable not defined" throw
  if [[ "$definition" =~ $regex ]]
  then
    local variableType
    local primitiveType=${BASH_REMATCH[1]}

    local objectTypeIndirect="$variableName[__object_type]"
    if [[ "$primitiveType" =~ [A] && ! -z "${!objectTypeIndirect}" ]]
    then
      DEBUG Log "typeof $variableName: Object Type $variableName[__object_type] = ${!objectTypeIndirect}"
      variableType="${!objectTypeIndirect}"
    else
      variableType="$(Variable::GetPrimitiveTypeFromDeclarationFlag "$primitiveType")"
      DEBUG Log "typeof $variableName: Primitive Type $primitiveType Resolved ${variableType}"
    fi

    if [[ "$variableType" == 'reference' && "$dereferrence" == 'true' ]]
    then
      local dereferrencedVariableName=$(Variable::PrintDeclaration "$variableName" false)
      variableType=$(Type::GetTypeOfVariable "$dereferrencedVariableName")
    fi

    if [[ "$variableType" == 'string' ]]
    then
      local extensionType=$(Type::GetPrimitiveExtensionFromVariable "${variableName}")
      if [[ ! -z "$extensionType" ]]
      then
        variableType="$extensionType"
      fi
    fi

    DEBUG Log "Variable $variableName is typeof $variableType"

    echo "$variableType"
  fi
}

Type::IsPrimitive() {
  local type="$1"

  case "$type" in
    'array'|'map'|'string'|'integer'|'boolean'|'integerArray'|'reference') ## TODO: reference should be resolved
      return 0 ;;
    * )
      return 1 ;;
  esac
}

## Returns a matching __primitive_extension_fingerprint__*
## Or nothing
Type::GetPrimitiveExtensionFromVariable() {
  local variableName="$1"

  if [[ "${!variableName}" != "$__primitive_extension_declaration"* ]]
  then
    return
  fi

  local prefix=__primitive_extension_fingerprint__
  local extensionType
  for extensionType in $(Variable::GetAllStartingWith $prefix)
  do
    local fingerprint=${!extensionType}
    if [[ "${!variableName}" == "$fingerprint"* ]]
    then
      extensionType=${extensionType##$prefix}
      echo "$extensionType"
      return
    fi
  done
}

Type::GetPrimitiveExtensionFingerprint() {
  local type="$1"

  local fingerprintVariable="__primitive_extension_fingerprint__${type}"
  printf "${!fingerprintVariable}"
}

Type::CreateHandlerFunction() {
  local variableName="$1"

  if [[ -z $variableName ]]
  then
    subject=WARN Log "No variable specified when trying to create a handle."
    return
  fi

  ## don't allow creating a handler if a command/function/alias of such name already exists
  ## unless it is a handler already (keeps track)

  if ! Command::Exists "${__oo__variableMethodPrefix}${variableName}"
  then
    DEBUG Log "creating handler for $variableName"
    ## declare method with the name of the var ##
    eval "${__oo__variableMethodPrefix}${variableName}() { Type::Handle $variableName \"\$@\"; }"
    __oo__type_handler_functions+=( "${variableName}" )

  elif ! Array::Contains "${variableName}" "${__oo__type_handler_functions[@]}"
  then
    ## TODO: a way to solve this is to store the original functions
    ## and temporairly override it, returning back to the old formula in @return
    subject=WARN Log "Unable to create a handle for '$variableName'. A command of the same name already exists."
  fi

  Type::RunFunctionGarbageCollector
}

Type::RunFunctionGarbageCollector() {
  local -a variables=( $(compgen -A 'variable' || true) )

  local index
  local handler
  for index in "${!__oo__type_handler_functions[@]}"
  do
    handler="${__oo__type_handler_functions[$index]}"

    local exists=
    for variable in "${variables[@]}"
    do
      # Log "comparing: ${variable} == $handler"
      [[ "$variable" == "$handler" ]] && { exists=1; break; }
    done
    ## unset all the functions that don't have corresponding variables
    if [[ ! -n $exists ]]
    then
      DEBUG Log "Unsetting handler for $handler"
      unset -f "${__oo__variableMethodPrefix}${handler}"
      unset __oo__type_handler_functions[$index]
    else
      DEBUG Log "not deleting: handler and variable exists: ${variable}"
    fi
  done
}

Type::InjectThisResolutionIfNeeded() {
  local methodName="$1"

  local methodBody=$(declare -f "$methodName" || true)

  if [[ -z "$methodBody" ]]
  then
    e="Method $methodName is not defined." throw
    return
  fi

  if [[ "$methodBody" != *'@resolve:this'* && "$methodBody" != *'__local_return_self_and_result=false'* ]]
  then
    DEBUG Log "Injecting @this resolution to: $methodName"
    DEBUG [[ "$methodName" == "Human"* ]] && Log "$methodBody"

    if [[ "$methodBody" != *'@return'* ]]
    then
      Function::InjectCode "$methodName" '@resolve:this' '@return'
    else
      Function::InjectCode "$methodName" '@resolve:this'
    fi
  fi
}

Type::ConvertAllOfTypeToMethodsIfNeeded() {
  local type="$1"

  local -a methods=( $(Function::GetAllStartingWith "${type}.") )
  local method

  for method in "${methods[@]}"
  do
    Type::InjectThisResolutionIfNeeded "$method"
  done
}

Type::InitializePrimitive() {
  local name="$1"

  Type::ConvertAllOfTypeToMethodsIfNeeded "$name"
}

Type::TrapAndCreate() {
  # USE DEFAULT IFS IN CASE IT WAS CHANGED
  local IFS=$' \t\n'

  local commandWithArgs=( $1 )
  local command="${commandWithArgs[0]}"

  shift

  # Log "${commandWithArgs[*]}"

  if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* ]]
  then
    # set +x
    return 0
  fi

  if [[ "${commandWithArgs[*]}" == "true" ]]
  then
    __typeCreate_next=true
    # Console::WriteStdErr "Will assign next one"
    # set +x
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

  # TODO: make this better, otherwise edge case bug:
  if [[ "$varValue" == "$varName" ]]
  then
    # Log "equal $varName=$varValue"
    local varValue=""
  fi

  if [[ ! -z $__typeCreate_varType ]]
  then

    local __primitive_extension_fingerprint__boolean=${__primitive_extension_fingerprint__boolean:-2D6A822E36884C70843578D37E6773C4}
    # Console::WriteStdErr "SETTING $__typeCreate_varName = \$$__typeCreate_paramNo"
    # Console::WriteStdErr --
    #Console::WriteStdErr $tempName

    DEBUG Log "creating: $__typeCreate_varName ($__typeCreate_varType) = $__typeCreate_varValue"

    if [[ -z "$__typeCreate_varValue" ]]
    then
      case "$__typeCreate_varType" in
        'array'|'map') eval "$__typeCreate_varName=()" ;;
        'string') eval "$__typeCreate_varName=''" ;;
        'integer') eval "$__typeCreate_varName=0" ;;
        'boolean') eval "$__typeCreate_varName=${__primitive_extension_fingerprint__boolean}:false" ;;
        * )
        # Log "constructing: $__typeCreate_varName ($__typeCreate_varType) = $(__constructor_recursion=0 Type::Construct $__typeCreate_varType)"

          __constructor_recursion=0 Type::Construct "$__typeCreate_varType" "$__typeCreate_varName"

          DEBUG Log "constructed: $(@get $__typeCreate_varName)"
        ;;
      esac
    else
      case "$__typeCreate_varType" in
        'boolean')
          if [[ "${__typeCreate_varValue}" != 'true' && "${__typeCreate_varValue}" != 'false' ]]
          then
            __typeCreate_varValue='false'
          fi
          eval "$__typeCreate_varName=\"${__primitive_extension_fingerprint__boolean}:${__typeCreate_varValue}\"" ;;
      ## TODO: add case of setting value already with fingerprint
        *) ;;
      esac
    fi

    Type::CreateHandlerFunction "$__typeCreate_varName"

    ## IMPORTANT: TRAP won't work inside a TRAP, so such a constructor couldn't

    # case "$__typeCreate_varType" in
    #   'array'|'map'|'string'|'integer') ;;
    #   *)
    #     if Function::Exists ${__typeCreate_varType}.constructor
    #     then
    #       # __typeCreate_runConstructor=${__typeCreate_varName}
    #       # Log __typeCreate_runConstructor $__typeCreate_runConstructor
    #       ${__typeCreate_varName} constructor
    #     fi
    #     # local return
    #     # Object.New $__typeCreate_varType $__typeCreate_varName
    #     # eval "$__typeCreate_varName=$return"
    #   ;;
    # esac

    # __oo__objects+=( $__typeCreate_varName )

    unset __typeCreate_varType
    unset __typeCreate_varValue
  fi

  if [[ "$command" != "declare" || "$__typeCreate_next" != "true" ]]
  then
    __typeCreate_normalCodeStarted+=1

  # Console::WriteStdErr "NOPASS ${commandWithArgs[*]}"
  # Console::WriteStdErr "normal code count ($__typeCreate_normalCodeStarted)"
  # Console::WriteStdErr --
  else
    unset __typeCreate_next

    __typeCreate_normalCodeStarted=0
    __typeCreate_varName="$varName"
    __typeCreate_varValue="$varValue"
    __typeCreate_varType="$__capture_type"
    __typeCreate_arrLength="$__capture_arrLength"

    # Console::WriteStdErr "PASS ${commandWithArgs[*]}"
    # Console::WriteStdErr --

    __typeCreate_paramNo+=1
  fi
  # set +x
}

Type::CaptureParams() {
    # Console::WriteStdErr "Capturing Type $_type"
    # Console::WriteStdErr --

    __capture_type="$_type"
}

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias Type::TrapAssign='Type::CaptureParams; declare -i __typeCreate_normalCodeStarted=0; trap "declare -i __typeCreate_paramNo; Type::TrapAndCreate \"\$BASH_COMMAND\" \"\$@\"; [[ \$__typeCreate_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __typeCreate_varType __typeCreate_varName __typeCreate_varValue __typeCreate_paramNo" DEBUG; true; true; '
alias reference='_type=reference Type::TrapAssign declare -n'
alias string='_type=string Type::TrapAssign declare'
alias boolean='_type=boolean Type::TrapAssign declare'
alias integer='_type=integer Type::TrapAssign declare -i'
alias array='_type=array Type::TrapAssign declare -a'
alias integerArray='_type=integerArray Type::TrapAssign declare -ai'
alias map='_type=map Type::TrapAssign declare -A'
#alias global:reference='_type=reference Type::TrapAssign declare -ng'
#alias global:string='_type=string Type::TrapAssign declare -g'
#alias global:integer='_type=integer Type::TrapAssign declare -ig'
#alias global:array='_type=array Type::TrapAssign declare -ag'
#alias global:map='_type=map Type::TrapAssign declare -Ag'

##############################

# for use in the object's methods
this() {
  __access_private=true Type::Handle this "$@"
}

var:this() {
  __access_private=true Type::Handle this "$@"
}

var:() {
  Type::Handle "$@"
  # Type::Handle $1 "${@:2}"
}

@return() {
  local variableName="$1"
  local thisName="${2:-this}"

  local __return_declaration
  local __return_declaration_type

  ## if not returning anything, just update the self
  if [[ ! -z "$variableName" ]]
  then
    Variable::ExportDeclarationAndTypeToVariables $variableName __return_declaration
  elif [[ ! -z "${monad+x}" ]]
  then
    Variable::ExportDeclarationAndTypeToVariables $thisName __return_declaration
  fi

  if [[ "${__local_return_self_and_result}" == "true" || "${__return_self_and_result}" == "true" ]]
  then
    # Log "returning heavy"
    local -a __return=("$(Variable::PrintDeclaration $thisName)" "$__return_declaration" "$__return_declaration_type")

    printf ${__return_separator:-52A586A48E074BB6812DCFDC790841F5}
    Variable::PrintDeclaration __return
    # __modifiedThis="$(Variable::PrintDeclaration this)"
  elif [[ "${#__return_declaration}" -gt 0 ]]
  then
    echo "$__return_declaration"
  fi

  Type::RunFunctionGarbageCollector
}

@return:value() {
  local value="$@"
  @return value
}

# ------------------------ #
# STACK HANDLING #
# ------------------------ #

Type::ExecuteMethod() {
  local type="$1"
  local variableName="$2"
  local method="$3"

  shift; shift; shift;

  Type::InjectThisResolutionIfNeeded "$type.$method"

  thisReference=$variableName thisReferenceType="$type" $type.$method "$@"
}

# /**
#  * used inside Type::Handle() for getting out the return value and updating this
#  */
Type::RunCurrentStack() {
  DEBUG Log "will execute: $method (${params[@]})"

  if [[ ! -z "$returnValueDefinition" && "$affectTheInitialVariable" == 'false' ]]
  then
    local -$(Variable::GetDeclarationFlagFromType $returnValueType) "__self=$returnValueDefinition"
    variableName=__self
  fi

  # Log "Will assign: result=$(__return_self_and_result=true Type::ExecuteMethod "$type" "$variableName" "$method" "${params[@]}")"
  local resultString=$(__return_self_and_result=true Type::ExecuteMethod "$type" "$variableName" "$method" "${params[@]}" || { local falseBool="${__primitive_extension_fingerprint__boolean}:false"; __return_self_and_result=true @return falseBool $variableName; })
  # || echo "${__return_separator}specialBool:${__primitive_extension_fingerprint__boolean}:false"

  ## TODO: some problem here sometimes
  DEBUG Log "Result string: START | $resultString | END"

  local echoed=

  if [[ -z "$resultString" || "$resultString" != *"$__return_separator"* ]]
  then
    ## if resultString does not contain return_separator, use all as returnString and nothing as echo
    ## TODO: debug these situations if all ok.
    # theoretically, this is when no @return is present
    # or when no return separator provided - we use the echoed output as the result
    #
    ## implicit "string"
    local -a result=( "$(@get $variableName)" "$(@get resultString)" "string" )
  else
    # echo everything before the first occurrence of the separator
    echoed="${resultString%%$__return_separator*}"

    DEBUG [[ ! -z "$echoed" ]] && Log "Echoed: START | $(@get echoed) | END"

    # the result is everything after the first occurrence of the separator
    resultString="${resultString#*$__return_separator}"

    # Log "resultString: $resultString"
    local -a result=$resultString
    # eval "local -a result=$resultString"
  fi

  unset __self

  # declare -p result
  local assignResult="${result[0]}"

  DEBUG Log "Assign Result:"
  DEBUG Log "START $assignResult END"
  # declare -p assignResult

  local typeParam=$(Variable::GetDeclarationFlagFromType $type)

  DEBUG Log "Will eval: | $variableName=$assignResult |"
  # [[ "${assignResult}" == "${__primitive_extension_fingerprint__boolean}:false" ]] && return 1

  if [[ "$typeParam" =~ [aA] ]]
  then
    # update the object
    eval "$variableName=$assignResult"
  else
    ## TODO: use the primitive extension fingerprint here, not in the methods themselves
    # assignResult="$(Type::GetPrimitiveExtensionFingerprint $type):$assignResult"
    eval "$variableName=\"\$assignResult\""
  fi

  # update the result
  returnValueDefinition="${result[1]}"
  returnValueType="${result[2]}"

  # Log "returned: $returnValueType: $returnValueDefinition"

  # switch context for the next command
  if [[ "$assignResult" != "${returnValueDefinition}" ]]
  then
    affectTheInitialVariable=false
    type="$returnValueType" # $(Variable::GetPrimitiveTypeFromDeclarationFlag $returnValueType)
  fi

  printf %s "$echoed"

  ## cleanup vars:
  method=''
  params=()

  # TODO: this should work directly but doesn't
  # eval $variableName=\$assignResult
}

Type::RunGetter() {
  local variableName="$1"
  local type="$2"

  if Function::Exists "$type.__getter__"
  then
    __return_self_and_result=false Type::ExecuteMethod "$type" "$variableName" "__getter__"
  else
    @get "$variableName"
  fi
}

## TODO: private handling should be reimplemented - only this() should be able to access private entries
Type::Handle() {
  local variableName="$1"
  local type=$(Type::GetTypeOfVariable "${variableName}")
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

  local currentPropertyVisibility=public

  local multiExpression=false

  if [[ "$1" == ':' ]]
  then
    multiExpression=true
    shift
  fi

  DEBUG subject="type handling" Log "START ANALYZING: type: $type | variable: $variableName $@"
  DEBUG subject="type handling" Log "WHAT: $(declare -p $variableName)"

  # Log multiExpression $multiExpression

  if [[ $# -gt 0 ]]
  then
    local method
    local -a params
    local mode=method
    local prevMode
    local prevModeNext
    local bracketsStarted=false
    local -i closingBracketCount=0

    while [[ $# -gt 0 ]]
    do
      if [[ "$__access_private" != "true" && "$currentPropertyVisibility" == "private" ]]
      then
        e="Trying to access a private property: $method" throw
        return
      fi

      prevModeNext=$mode

      if [[ $multiExpression == 'true' ]] && [[ "$1" == '{' ]]
      then
        if [[ $bracketsStarted == 'true' ]]
        then
          ## handle edge case of '}' as actual parameter
          while (( closingBracketCount+=-1 ))
          do
            params+=( '}' )
          done

          Type::RunCurrentStack
        fi
        bracketsStarted=true
        # mode=params
      elif [[ $multiExpression == 'true' ]] && [[ "$1" == '}' ]]
      then
        closingBracketCount+=1
        mode=method
        prevModeNext=params
      elif [[ "$mode" == 'params' ]]
      then
        params+=("$1")
      elif [[ "$mode" == 'method' ]]
      then
        # Log $(@get __${type}_property_names | array.indexOf $1) $1 idx
        # Log $(@get __${type}_property_names | array.contains $1 && echo t)

        # Log index __${type}_property_names $(@get __${type}_property_names | __return_self_and_result=false array.indexOf ${1})

        local typeSanitized=$(String::SanitizeForVariableName ${type})
        # local typeSanitized="${type//[^a-zA-Z0-9]/_}"

        if Variable::Exists __${typeSanitized}_property_names &&
            @get __${typeSanitized}_property_names | __return_self_and_result=false array.contains $1
        then
          # stack now belongs to selected property:
          local property="$1"

          DEBUG Log found index __${type}_property_names $(@get __${type}_property_names | __return_self_and_result=false array.indexOf ${property})
          # Log prop: $property of [$(@get __${type}_property_names)]

          ## TODO: theoretically, we could get rid of: __return_self_and_result=false
          local -i index=$(@get __${typeSanitized}_property_names | __return_self_and_result=false array.indexOf ${property})

          if [[ $index -ge 0 ]]
          then
            DEBUG Log "traversing to a child property $property of type $type"

            local newType=__${typeSanitized}_property_types[$index]
            type=${!newType}
            local typeParam=$(Variable::GetDeclarationFlagFromType $type)

            local currentPropertyVisibilityIndirect=__${typeSanitized}_property_visibilities[$index]
            currentPropertyVisibility=${!currentPropertyVisibilityIndirect}

            local propertyValueIndirect=$variableName[$property]

            if [[ -z "${!propertyValueIndirect}" && "$typeParam" =~ [aA] ]]
            then
              local -$typeParam "__$property=()"
            else
              ## TODO: check if this preserves spaces correctly
              local -$typeParam "__$property=${!propertyValueIndirect}"

              if ! Type::IsPrimitive "$type"
              then
                eval "__$property[__object_type]=\"\$type\""
              fi
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
          mode=params
          method="$1"
        fi
      fi
      prevMode=$prevModeNext

      DEBUG subject="type handling" Log "iter: $1 | prevMode: $prevMode | mode: $mode | type: $type | variable: $variableName | method: $method | #params: ${#params[@]}"

      shift
    done

    if [[ "${#method}" -gt 0 ]]
    then
      # Log 'running stack for:' $variableName
      Type::RunCurrentStack
      # Log 'output was:' "${!variableName}"
      ## TODO: this does not work: (false boolean should return fail)
      [[ "${!variableName}" == "${__primitive_extension_fingerprint__boolean}:false" ]] && return 1 # && Log "LALALALA"
    elif [[ "$prevMode" == 'property' ]]
    then
      if [[ "$currentPropertyVisibility" == 'public' || "$__access_private" == "true" ]]
      then
        DEBUG subject='property' Log 'print out the property' $variableName
        ## print out the property or run the getter
        Type::RunGetter $variableName $type
      else
        e="Property is private" throw
      fi
    fi

    ## TODO: shouldn't this be an elif ?
    # finally echo the latest return value if not empty
    if [[ ! -z "$returnValueDefinition" ]]
    then
      echo "$returnValueDefinition"
    fi

    ## UPDATE THE OBJECT RECURSIVELY:
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
    #@get $variableName
    Type::RunGetter $variableName $type
  fi
}

## TODO: take note of what variables have handler functions in a global variable
## in @resolve:this save the list and then compare it in a @return
## -- or better yet -- to it in the parent that executes the method
## before and after execution

## question - how to add @resolve:this to all methods without explicitly stating it?

## "garbage collect", i.e. remove all the new references so they don't pollute the global scope

## note: declaration needs to be trimmed,
## since bash adds an enter at the end, hence %?
alias @resolve:this="
  local __local_return_self_and_result=false
  [[ \$__return_self_and_result == 'true' ]] && local __local_return_self_and_result=true && local __return_self_and_result=false
  # TODO: local __access_private_members_of=
  if [[ -z \${__use_this_transparently+x} ]];
  then
    local __declaration;
    local __declaration_type;

    if [[ ! -z \"\${useReturnValueDefinition}\" ]];
    then
      # subject='@resolve:this' Log 'using: ReturnValueDefinition'
      __declaration=\"\$returnValueDefinition\"
      __declaration_type=\$returnValueType
    elif [[ -z \${thisReference+x} && ! -t 0 ]];
    then
      # subject='@resolve:this' Log 'using: pipe'
      Pipe::Capture __declaration;
      __declaration_type=\${FUNCNAME[0]%.*}
      DEBUG Log capturing via pipe \${__declaration_type}
    else
      # subject='@resolve:this' Log 'using: thisReference:' $ \$thisReference type: \$thisReferenceType
      Variable::ExportDeclarationAndTypeToVariables \$thisReference __declaration;
      __declaration_type=\"\$thisReferenceType\"
      unset thisReference;
    fi;

    local typeParam=\$(Variable::GetDeclarationFlagFromType \"\${__declaration_type}\" '-');
    # subject='@resolve:this' Log \$__declaration_type = \$typeParam = \$__declaration

    # TODO: does it preserve spaces properly?
    local -\$typeParam this=\${__declaration};

    ## add type for objects that don't have them set explicitly
    if [[ \$typeParam == 'A' && \$__declaration_type != 'map' && -z \${this[__object_type]+x} ]]
    then
      # Log setting object type
      this[__object_type]=\"\$__declaration_type\"
    fi

    unset __declaration;
    unset __declaration_type;
  fi
  "

# ------------------------ #

import TypePrimitives
