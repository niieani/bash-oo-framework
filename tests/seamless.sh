#!/usr/bin/env bash

#__INTERNAL_LOGGING__=true
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

namespace seamless

Log::AddOutput seamless CUSTOM
Log::AddOutput error ERROR
#Log::AddOutput oo/parameters-executing CUSTOM

alias ~="Exception::CustomCommandHandler"

declare -Ag __oo__objectToType
declare -Ag __oo__objectToName
obj=OBJECT

Type.CreateVar() {
    # USE DEFAULT IFS IN CASE IT WAS CHANGED
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
        # Console::WriteStdErr "Will assign next one"
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
      # Console::WriteStdErr "SETTING $__typeCreate_varName = \$$__typeCreate_paramNo"
      # Console::WriteStdErr --
      #Console::WriteStdErr $tempName

    	DEBUG Log "creating $__typeCreate_varName ($__typeCreate_varType) = $__typeCreate_varValue"

    	if [[ -z "$__typeCreate_varValue" ]]
      then
        case "$__typeCreate_varType" in
          'array'|'dictionary') eval "$__typeCreate_varName=()" ;;
          'string') eval "$__typeCreate_varName=''" ;;
          'integer') eval "$__typeCreate_varName=0" ;;
          * ) ;;
        esac
      fi

      case "$__typeCreate_varType" in
        'array'|'dictionary'|'string'|'integer') ;;
        *)
          local return
          Object.New $__typeCreate_varType $__typeCreate_varName
          eval "$__typeCreate_varName=$return"
        ;;
      esac

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
}

Type::CaptureParams() {
    # Console::WriteStdErr "Capturing Type $_type"
    # Console::WriteStdErr --

    __capture_type="$_type"
}

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias trapAssign='Type::CaptureParams; declare -i __typeCreate_normalCodeStarted=0; trap "declare -i __typeCreate_paramNo; Type.CreateVar \"\$BASH_COMMAND\" \"\$@\"; [[ \$__typeCreate_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __typeCreate_varType && unset __typeCreate_varName && unset __typeCreate_varValue && unset __typeCreate_paramNo" DEBUG; true; true; '
alias reference='_type=reference trapAssign declare -n'
alias string='_type=string trapAssign declare'
alias int='_type=integer trapAssign declare -i'
alias array='_type=array trapAssign declare -a'
alias dictionary='_type=dictionary trapAssign declare -A'

alias TestObject='_type=TestObject trapAssign declare'

declare -Ag __oo__garbageCollector


# we don't need to define anything if using command_not_found
# we only need to check what type that variable is!
# and return whatever we need!
# it also means we can PIPE to a variable/object
# echo dupa | someArray.Add

alias ~modifiesLocals="[[ \"\${FUNCNAME[2]}\" != \"command_not_found_handle\" ]] || subject=warn Log \"Method \$FUNCNAME modifies locals and needs to be run prefixed by '@'\""

writeln() ( # forking for local scope for $IFS
	local IFS=" " # needed for "$*"
	printf '%s\n' "$*"
)

write() (
	local IFS=" "
	printf %s "$*"
)

writelne() (
	local IFS=" "
	printf '%b\n' "$*"
)

String.GetRandomAlphanumeric() {
    # http://stackoverflow.com/a/23837814/595157
    local chars=( {a..z} {A..Z} {0..9} )
    local length=$1
    local ret=
    while ((length--))
    do
        ret+=${chars[$((RANDOM%${#chars[@]}))]}
    done
    printf '%s\n' "$ret"
}

Object.New() {
	local objectUUID=$obj:$(String.GetRandomAlphanumeric 12)
	__oo__objectToType[$objectUUID]="$1"
	__oo__objectToName[$objectUUID]="$2"

	return=$objectUUID
}

Object.Invoke() {
	[string] objectUUID
	# remainingStack[]
	[string] stackElement
	[...rest] params

	if [[ -z ${__oo__objectToType[$objectUUID]+isSet} ]]
	then
		e="Object $objectUUID doesn't exist" throw "$stackElement" && return 0
	fi

	${__oo__objectToType[$objectUUID]}.$stackElement "${params[@]}"
}

class:TestObject() {
	var name
	int age=30

	# if parent function starts with "class:"
	# capture and save
}

TestObject.__constructor__() {
	this.age=20

}

TestObject.Hello() {
	echo Hello!
	alias Opica="local hello_sub1=wtf; local hello_sub2=lol; "
}

Object.IsObject() {
	:
}

Object.GetType() {
	:
}

Reference.GetRealVariableName() {
	local realObject="$1"
	# local typeInfo="$(declare -p $realObject 2> /dev/null || declare -p | grep "^declare -[aAign\-]* $realObject\(=\|$\)" || true)"
	local typeInfo="$(declare -p $realObject 2> /dev/null || true)"

	if [[ -z "$typeInfo" ]]
	then
		DEBUG local extraInfo="$(declare -p | grep "^declare -[aAign\-]* $realObject\(=\|$\)" || true)"
		DEBUG subject="dereferrenceNoSuccess" Log "$extraInfo"
		echo "$realObject"
		return 0
	fi

	#DEBUG subject="dereferrence" Log "$realObject to $typeInfo"
	# dereferrence
	while [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
	do
		DEBUG subject="dereferrence" Log "$realObject to ${BASH_REMATCH[1]}"
		realObject=${BASH_REMATCH[1]}
		typeInfo="$(declare -p $realObject 2> /dev/null)" # || declare -p | grep "^declare -[aAign\-]* $realObject\(=\|$\)"
	done

	echo "$realObject"
}

Type::GetTypeOfVariable() {
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
		echo dictionary
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

# insted of echo let's use $return
# return="something"
# return should be declared prior to entering the func

~returns() {
	[string] returnType
	# switch case array
	# check if $return is an array
	# etc...
	#:

	# initialize/reset return variable:
	case "$returnType" in
		'array' | 'dictionary') return=() ;;
		'string' | 'integer') return="";;
		*) ;;
	esac

	# DEBUG subject="returnsMatch" Log
	local realVar=$(Reference.GetRealVariableName return)
	local type=$(Type::GetTypeOfVariable $realVar)

	if [[ "$returnType" != "$type" ]]
	then
		e="Return type ($returnType) doesn't match with the actual type ($type)." throw
	fi
}

string.length() {
	return=${#this}
}

string.toUpper() {
	return="${this^^}"
}

array.length() {
	~returns int
	return=${#this[@]}
}

string.sanitized() {
    local sanitized="${this//[^a-zA-Z0-9]/_}"
    return="${sanitized^^}"
}

string.toArray() {
	#[reference] array
	~modifiesLocals

	local newLine=$'\n'
	local separationCharacter=$'\UFAFAF'
	local string="${this//"$newLine"/"$separationCharacter"}"
	local IFS=$separationCharacter
	local element
	for element in $string
	do
		return+=( "$element" )
	done

	local newLines=${string//[^$separationCharacter]}
	local -i trailingNewLines=$(( ${#newLines} - ${#return[@]} + 1 ))
	while (( trailingNewLines-- ))
	do
		return+=( "" )
	done
}

array.print() {
	local index
	for index in "${!this[@]}"
	do
		echo "$index: ${this[$index]}"
	done
}

# string.change() {
# 	## EXAMPLE
# 	~modifiesLocals
# 	# [[ "${FUNCNAME[2]}" != "command_not_found_handle" ]] || s=warn Log "Method $FUNCNAME modifies locals and needs to be run prefixed by '@'."
# 	this="$1"
# 	DEBUG Log "change list: $*"
# }

string.match() {
	[string] regex
	[integer] capturingGroup=${bracketParams[0]} #bracketParams
	[string] returnMatch="${bracketParams[1]}"

	DEBUG subject="string.match" Log "string to match on: $this"

	array allMatches
	~ allMatches~=this.matchGroups "$regex" "$returnMatch"

	return="${allMatches[$capturingGroup]}"
}

string.matchGroups() {
	~returns array
	[string] regex
	# [reference] matchGroups
	[string] returnMatch="${bracketParams[0]}"

	DEBUG subject="matchGroups" Log "string to match on: $this"
	local -i matchNo=0
	local string="$this"
	while [[ "$string" =~ $regex ]]
	do
		DEBUG subject="regex" Log "match $matchNo: ${BASH_REMATCH[*]}"

		if [[ "$returnMatch" == "@" || $matchNo -eq "$returnMatch" ]]
		then
			return+=( "${BASH_REMATCH[@]}" )
			[[ "$returnMatch" == "@" ]] || return 0
		fi
		# cut out the match so we may continue
		string="${string/"${BASH_REMATCH[0]}"}" # "
		matchNo+=1
	done
}

array.takeEvery() {
	~returns array
	[integer] every
	[integer] startingIndex
	# [reference] outputArray

	local -i count=0

	local index
	for index in "${!this[@]}"
	do
		if [[ $index -eq $(( $every * $count + $startingIndex )) ]]
		then
			#echo "$index: ${this[$index]}"
			return+=( "${this[$index]}" )
			count+=1
		fi
	done
}

array.last() {
	~returns string

	local count="${#this[@]}"
	return="${this[($count-1)]}"
}

array.add() {
	[string] element

	this+=( "$element" )
}

array.forEach() {
	[string] elementName
	[string] do

	# first dereferrence
	# local typeInfo="$(declare -p this)"
	# if [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
	# then
	# 	local realName=${BASH_REMATCH[1]}
	# fi

	local index
	for index in "${!this[@]}"
	do
		local $elementName="${this[$index]}"
		# local -n $elementName="$realName[$index]"
		# local -n $elementName="this[$index]"
		eval "$do"
		# unset -n $elementName
	done
}

Exception::CustomCommandHandler() {
	# best method for checking if variable is declared: http://unix.stackexchange.com/questions/56837/how-to-test-if-a-variable-is-defined-at-all-in-bash-prior-to-version-4-2-with-th
	if [[ ! "$1" =~ \. ]] && [[ -n ${!1+isSet} ]] && [[ -z "${*:2}" ]]
	then
		# check if an object UUID
		# else print var

		DEBUG subject="builtin" Log "Invoke builtin getter"
		# echo "var $1=${!1}"
		echo "${!1}"
		return 0
	fi

	local regex='(^|\.)([a-zA-Z0-9_]+)(({[^}]*})*)((\[[^]]*\])*)((\+=|-=|\*=|/=|==|\+\+|~=|:=|=|\+|/|\\|\*|~|:|-)(.*))*'

	local -a matches
	local -n return=matches; this="$1" bracketParams=@ string.matchGroups "$regex"; unset -n return

	if (( ${#matches[@]} == 0 ))
	then
		return 1
	fi

	local -a callStack
	local -a callStackParams
	local -a callStackLastParam
	local -a callStackBrackets
	local -a callStackLastBracket
	local callOperator="${matches[-2]}"
	local callValue="${matches[-1]}"

	#unset -n this
	local originalThisReference="$(Reference.GetRealVariableName this)"
	DEBUG [[ ${originalThisReference} == this ]] || subject="originalThisReference" Log $originalThisReference
	[[ ${originalThisReference} != this ]] || local originalThis="$this"

	local -n this="matches"
		local -n return=callStack; array.takeEvery 10 2; unset -n return
		local -n return=callStackParams; array.takeEvery 10 3; unset -n return
		local -n return=callStackLastParam; array.takeEvery 10 4; unset -n return
		local -n return=callStackBrackets; array.takeEvery 10 5; unset -n return
		local -n return=callStackLastBracket; array.takeEvery 10 6; unset -n return
	unset -n this

	DEBUG local -n this="callStack"
		DEBUG subject="complex" Log callStack:
		DEBUG array.print
	DEBUG unset -n this

	DEBUG local -n this="callStackParams"
		DEBUG subject="complex" Log callStackParams:
		DEBUG array.print
	DEBUG unset -n this

	DEBUG local -n this="callStackBrackets"
		DEBUG subject="complex" Log callStackBrackets:
		DEBUG array.print
	DEBUG unset -n this

	# restore the this reference/value:
	[[ ${originalThisReference} == this ]] || local -n this="$originalThisReference"
	[[ -z ${originalThis} ]] || local this="$originalThis"

	#DEBUG subject="complex" Log this: ${this[@]}
	DEBUG subject="complex" Log callOperator: $callOperator
	DEBUG subject="complex" Log callValue: $callValue

	local -i callLength=$((${#callStack[@]} - 1))
	local -i callHead=1

	DEBUG subject="complex" Log callLength: $callLength

	local rootObject="${callStack[0]}"

	## TODO: also check if rootObject is a function - the call it if it is
	## i.e. we allow calling myFunction[param][param]{param}{param}

	# check for existance of $callStack[0] and whether it is an object
	# if is resolvable immediately
	local rootObjectResolvable=$rootObject[@]
	if [[ -n ${!rootObjectResolvable+isSet} || "$(eval "echo \" \${!$rootObject*} \"")" == *" $rootObject "* ]]
	then
		local realVar=$(Reference.GetRealVariableName $rootObject)
		local type=$(Type::GetTypeOfVariable $realVar)
		DEBUG subject="variable" Log "Variable \$$realVar of type: $type"

		if [[ $type == array || $type == dictionary ]] && [[ ! -z "${callStackBrackets[0]}" ]]
		then
			type=string
			rootObject="$rootObject${callStackBrackets[0]}"
		fi

		if [[ $type == string && "${!rootObject}" == "$obj:"* ]]
		then
			# local isObject=true
			# pass the rest of the call stack to the object invoker
			Object.Invoke "${!rootObject}" "${@:2}"
			return 0
		fi

		if (( $callLength == 0 )) && [[ -n "$callOperator" ]] #&& [[ $isObject != true ]]
		then
			DEBUG subject="complex" Log "CallStack length is 0, using the operator."
			case "$callOperator" in
				'~=')
					  if [[ "${!callValue}" == "$obj:"* && -z "${*:2}" ]]
					  then
					    # TODO: rather than eval, use a local -n target="$rootObject"
					  	eval "$rootObject=\"\${!callValue}\""
					  elif [[ -n "${callValue}" ]]
				  	  then
				  	  	#unset -n this
				  	    local -n returnVariable="$rootObject"
				  	    __oo__useReturnVariable=true ~ "$callValue" "${@:2}"
				  	    # eval "@ $callValue \"\${@:2}\""
				  	    unset -n returnVariable
					  fi
					  DEBUG subject="complexAssignment" Log "$rootObject=${!rootObject}"
				  ;;
			  # TODO: other operators
			  # $type.$callOperator "$callValue" "${@:2}"
			esac
		else
			# if [[ $isObject != true ]]
			# then
				local value=""

				case "$type" in
					"array"|"dictionary") local -n this="$rootObject" ;;
					"integer"|"string") value="${!rootObject}" ;;
				esac
			# fi

			# make it possible to also call functions through the use of first parameter:
			# ex.  ~ coolStuff add $ref:something
			# so, if 'coolStuff' is a VAR, then depending on it's type
			# runs it runs TYPE.add $ref:something
			if (( $callLength == 0 ))
			then
				callLength+=1
				callStack[1]="$2"
				shift
			fi

			while ((callLength--))
			do
				DEBUG subject="complex" Log calling: $type.${callStack[$callHead]}
				# does the method exist?
				if ! Function::Exists $type.${callStack[$callHead]}
				then
					e="Method: $type.${callStack[$callHead]} does not exist." skipBacktraceCount=4 throw ${callStack[$callHead]}
				fi

				local -a mustacheParams=()
				local mustacheParamsRegex='[^{}]+'
				local -n return=mustacheParams; this="${callStackParams[$callHead]}" string.matchGroups "$mustacheParamsRegex" @; unset -n return

				local -a bracketParams=()
				local bracketRegex='[^][]+'
				local -n return=bracketParams; this="${callStackBrackets[$callHead]}" string.matchGroups "$bracketRegex" @; unset -n return

				DEBUG subject="complex" Log bracketParams: ${bracketParams[*]} #${callStackParams[$callHead]}
				DEBUG subject="complex" Log mustacheParams: ${mustacheParams[*]} #${callStackBrackets[$callHead]}
				DEBUG subject="complex" Log --

				#local originalThis="$(Reference.GetRealVariableName this)"


				if (( $callHead == 1 )) && ! [[ "$type" == "string" || "$type" == "integer" ]]
				then
					DEBUG subject="complexA" Log "Executing: $type.${callStack[$callHead]} ${*:2}"
					$type.${callStack[$callHead]} "${mustacheParams[@]}" "${@:2}"
				else
					DEBUG subject="complexB" Log "Executing: this=$value $type.${callStack[$callHead]} ${mustacheParams[*]} ${*:2}"

					local retVal
					if [[ -n ${__oo__useReturnVariable+isSet} ]]
					then
						local -n return=returnVariable
					else
						local -n return=retVal
					fi

					this="$value" $type.${callStack[$callHead]} "${mustacheParams[@]}" "${@:2}"
					unset -n return
					value="$retVal"
				fi

				callHead+=1
			done

			# don't polute with a "this" reference
			unset -n this

			if [[ -n ${value} ]]
			then
				echo "${value}"
			fi
		fi

		#DEBUG subject="complex" Log "Invoke type: $type, object: $rootObject, ${child:+child: $child, }${bracketOperator:+"$bracketOperator: $bracketParams, "}operator: $operator${parameter:+, param $parameter}"

		#$type${child:+".$child"} "${@:2}"
	else
		#eval "echo \" \${!$rootObject*} \""
		DEBUG subject=Error Log ${rootObjectResolvable} is not resolvable: ${!rootObjectResolvable}
		return 1
	fi
	# if callOperator then for sure an object - check if exists, else error

}

# testFunc() {
	# local testing="onething.object['abc def'].length[123].something[2]{another}"
	#local testing="something.somethingElse{var1,var2,var3}[a].extensive{param1 : + can be =\"anything \"YO # -yo space}{another}[0][2]=LALALA} and what if=we have.an equals.test[immi]{lol}?"
	# local something="haha haha Yo!"
	# local testing="something.sanitized{}.length{}"
	# local -a dupa
	# dupa~=something.toArray -- use dupa as output parameter/ret-val
	#local regex='(?:^|\.)([a-zA-Z0-9_]+)((?:{.*?})*)((?:\[.*?\])*)(?:(=|\+|/|\\|\*|~|:|-|\+=|-=|\*=|/=|==)(.*))*'

# testFunc

# Object.Hello

# myFunction() {
#     array something # creates object "something" && __oo__garbageCollector+=( something ) local -a something
#     array another
#     something.add "blabla"
#     something.add $ref:something
#     # for member in "${something[@]}"
#     Array.Merge $ref:something $ref:another
# }

# myFunction




testFunc2() {
	string something="haha haha Yo!"
	string another="hey! works!"

	array coolStuff=(a bobo)

	echo $something
	something.length

	coolStuff.print
	~ coolStuff.add{$ref:something}
	coolStuff.print

	# Object mikrofalowka
	#=> echo $mikrofalowka result unreachable

  #=> $mikrofalowka result unreachable
	# mikrofalowka Hello

	# Opica
	# echo $hello_sub1

	# ~ coolStuff.add{$ref:something}
	# ~ coolStuff.add{$ref:another}
	# coolStuff.print

	# string lol
	# lol="$(coolStuff[1].toUpper.match{'WOR.*'}[0][0])"
	# lol

	# coolStuff
	# ~ coolStuff add something
	# coolStuff print
	#coolStuff[1]
	# ~ something~=something toUpper
	# something

	# for creating objects we can use
	# SomeType objectName

	# always save a full stack
	# for each created object at moment of creation

	# something
	# another
	# something.sanitized{}.length{}.length{}
	# something.sanitized{}
	# ~ something~="another.sanitized{}"
	# something
	# local -a someArray=()
	# ~ someArray~=something.match{'WOR.*'}[0][0]
	# someArray.print

	# string stringArray="$(echo -e "ba\nok\nmimi\nlol")"
	# array fromStringArray

	# ~ stringArray~=stringArray.toUpper
	# ~ fromStringArray~=stringArray.toArray{}
	# fromStringArray.print
}

testFunc2

# new method for a type system:
#
# command_not_found_handle() {
# 	echo hi, "$*" "${!2}"
# }
# declare jasia="haha"
# dupa jasia

# readPipe() {
# 	read it
# 	read
# }

# shopt -s lastpipe
# echo "hello world" | readPipe
# echo $it
