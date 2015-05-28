#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

namespace seamless

Log.AddOutput seamless CUSTOM
#Log.AddOutput oo/parameters-executing CUSTOM

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

    local varDeclaration="${commandWithArgs[1]}"
    if [[ $varDeclaration == '-'* ]]
    then
        varDeclaration="${commandWithArgs[2]}"
    fi
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"

    if [[ ! -z $__typeCreate_varType ]]
    then
        # Console.WriteStdErr "SETTING $__typeCreate_varName = \$$__typeCreate_paramNo"
        # Console.WriteStdErr --
        #Console.WriteStdErr $tempName

    	Console.WriteStdErr "creating $__typeCreate_varName ($__typeCreate_varType)"
    	
    	# __oo__objects+=( $__typeCreate_varName )

        unset __typeCreate_varType
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
alias trapAssign='Type.CaptureParams; declare -i __typeCreate_normalCodeStarted=0; trap "declare -i __typeCreate_paramNo; Type.CreateVar \"\$BASH_COMMAND\" \"\$@\"; [[ \$__typeCreate_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __typeCreate_varType && unset __typeCreate_varName && unset __typeCreate_paramNo" DEBUG; true; true; '
alias reference='_type=reference trapAssign declare -n'
alias var='_type=var trapAssign declare'
alias int='_type=int trapAssign declare -i'
alias array='_type=array trapAssign declare -a'
alias dictionary='_type=dictionary trapAssign declare -A'

myFunction() {
    array something # creates object "something" && __oo__garbageCollector+=( something ) local -a something
    array another
    something.Add "blabla"
    something.Add $ref:something
    # for member in "${something[@]}"
    Array.Merge $ref:something $ref:another
}

declare -Ag __oo__garbageCollector


# we don't need to define anything if using command_not_found
# we only need to check what type that variable is!
# and return whatever we need!
# it also means we can PIPE to a variable/object
# echo dupa | someArray.Add

alias @modifiesLocals="[[ \"\${FUNCNAME[2]}\" != \"command_not_found_handle\" ]] || subject=warn Log \"Method \$FUNCNAME modifies locals and needs to be run prefixed by '@'\""

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

obj=OBJECT

Object.New() {
	local ObjectUUID=$obj:$(String.GetRandomAlphanumeric 12)
}

Object.IsObject() {
	:
}

Object.GetType() {
	:
}

# insted of echo let's use $return
# return="something"
# return should be declared prior to entering the func

@returns() {
	@var returnType
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

	local typeInfo="$(declare -p return)"

	# first dereferrence
	# maybe this should be "while" for recursive dereferrence?
	while [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
	do
		local realObject=${BASH_REMATCH[1]}
		typeInfo="$(declare -p $realObject)"
	done

	if [[ "$typeInfo" == "declare -a"* ]]
	then
		local type=array
	elif [[ "$typeInfo" == "declare -A"* ]]
	then
		local type=dictionary
	elif [[ "$typeInfo" == "declare -i"* ]]
	then
		local type=integer
	elif [[ "${!realObject}" == "$obj:"* ]]
	then
		local type=$(Object.GetType "${!realObject}")
	else
		local type=string
	fi

	if [[ "$returnType" != "$type" ]]
	then
		e="Return type ($returnType) doesn't match with the actual type ($type)." throw
	fi

}

string.length() {
	echo ${#this}
}

array.length() {
	@returns int
	return=${#this[@]}
}

string.sanitized() {
    local sanitized="${this//[^a-zA-Z0-9]/_}"
    echo "${sanitized^^}"
}

string.toArray() {
	@reference array
	@modifiesLocals

	local newLine=$'\n'
	local separationCharacter=$'\UFAFAF'
	local string="${this//"$newLine"/"$separationCharacter"}"
	local IFS=$separationCharacter
	local element
	for element in $string
	do
		array+=( "$element" )
	done

	local newLines=${string//[^$separationCharacter]}
	local -i trailingNewLines=$(( ${#newLines} - ${#array[@]} + 1 ))
	while (( trailingNewLines-- ))
	do
		array+=( "" )
	done
}

array.print() {
	local index
	for index in "${!this[@]}"
	do
		echo "$index: ${this[$index]}"
	done
}

string.change() {
	## EXAMPLE
	@modifiesLocals
	# [[ "${FUNCNAME[2]}" != "command_not_found_handle" ]] || s=warn Log "Method $FUNCNAME modifies locals and needs to be run prefixed by '@'."
	this="somethingElse"
}

string.match() {
	@var regex
	@int capturingGroup=${bracketParam[0]} #bracketParam
	@var returnMatch="${bracketParam[1]}"

	local -a matches
	string.matchGroups "$regex" matches "$returnMatch"
	echo "${matches[$capturingGroup]}"
}

string.matchGroups() {
	@returns array
	@var regex
	# @reference matchGroups
	@var returnMatch="${bracketParam[0]}"

	local -i matchNo=0
	local string="$this"
	while [[ "$string" =~ $regex ]]
	do
		subject="regex" Log "match $matchNo: ${BASH_REMATCH[*]}"

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
	@returns array
	@int every
	@int startingIndex
	# @reference outputArray

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
	local count="${#this[@]}"
	echo "${this[($count-1)]}"
}

array.forEach() {
	@var elementName
	@var do

	# first dereferrence
	local typeInfo="$(declare -p this)"
	if [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
	then
		local realName=${BASH_REMATCH[1]}
	fi

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

alias @="Exception.CustomCommandHandler"
Exception.CustomCommandHandler() {
	if [[ ! "$1" =~ \. ]] && [[ -n ${!1+isSet} ]]
	then
		# check if an object UUID
		# else print var
		subject="builtin" Log "Invoke builtin getter"
		# echo "var $1=${!1}"
		echo "${!1}"
	else
		local regex='(^|\.)([a-zA-Z0-9_]+)(({[^}]*})*)((\[[^]]*\])*)((\+=|-=|\*=|/=|==|\+\+|~=|:=|=|\+|/|\\|\*|~|:|-)(.*))*'

		local -a matches
		local -n return=matches; this="$1" bracketParam=@ string.matchGroups "$regex"; unset -n return

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

		local -n this="matches"
			local -n return=callStack; array.takeEvery 10 2; unset -n return
			local -n return=callStackParams; array.takeEvery 10 3; unset -n return
			local -n return=callStackLastParam; array.takeEvery 10 4; unset -n return
			local -n return=callStackBrackets; array.takeEvery 10 5; unset -n return
			local -n return=callStackLastBracket; array.takeEvery 10 6; unset -n return
		unset -n this

		local -n this="callStack"
			subject="complex" Log callStack:
			array.print
		unset -n this

		local -n this="callStackParams"
			subject="complex" Log callStackParams:
			array.print
		unset -n this
		
		local -n this="callStackBrackets"
			subject="complex" Log callStackBrackets:
			array.print
		unset -n this

		subject="complex" Log callOperator: $callOperator
		subject="complex" Log callValue: $callValue
		subject="complex" Log

		local -i callLength=$((${#callStack[@]} - 1))
		local -i callHead=1

		subject="complex" Log callLength: $callLength

		local rootObject="${callStack[0]}"

		# check for existance of $callStack[0] and whether it is an object
		# if is resolvable immediately
		local rootObjectResolvable=$rootObject[@]
		if [[ -n ${!rootObjectResolvable+isSet} ]]
		then
			local typeInfo="$(declare -p $rootObject)"

			# first dereferrence
			# maybe this should be "while" for recursive dereferrence?
			while [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
			do
				rootObject=${BASH_REMATCH[1]}
				typeInfo="$(declare -p $rootObject)"
			done

			if [[ "$typeInfo" == "declare -a"* ]]
			then
				local type=array
				local -n this="$rootObject"
			elif [[ "$typeInfo" == "declare -A"* ]]
			then
				local type=dictionary
				local -n this="$rootObject"
			elif [[ "$typeInfo" == "declare -i"* ]]
			then
				local type=integer
				local value="${!rootObject}"
			elif [[ "${!rootObject}" == "$obj:"* ]]
			then
				# pass the rest of the call stack to the object invoker
				Object.Invoke "${!rootObject}" "${@:2}"
				return 0
			else
				local type=string
				local value="${!rootObject}"
			fi

			if (( $callLength == 1 )) && [[ -n "$callOperator" ]]
			then
				subject="complex" Log "CallStack length is 1, using the operator."
				$type.$callOperator "$callValue" "${@:2}"
			else
				while ((callLength--))
				do
					subject="complex" Log calling: $type.${callStack[$callHead]}
					# does the method exist?
					if ! Function.Exists $type.${callStack[$callHead]}
					then
						e="Method: $type.${callStack[$callHead]} does not exist." throw
					fi

					local -a mustacheParams=()
					local mustacheParamsRegex='[^{}]+'
					local -n return=mustacheParams; this="${callStackParams[$callHead]}" bracketParam=@ string.matchGroups "$mustacheParamsRegex"; unset -n return

					local -a brackets=()
					local bracketRegex='[^[]]+'
					local -n return=brackets; this="${callStackBrackets[$callHead]}" bracketParam=@ string.matchGroups "$bracketRegex" brackets; unset -n return

					subject="complex" Log brackets: ${brackets[*]} #${callStackParams[$callHead]}
					subject="complex" Log mustacheParams: ${mustacheParams[*]} #${callStackBrackets[$callHead]}
					subject="complex" Log --

					# if (( $callLength == 1 )) && [[ -n "$callOperator" ]]
					# then
					if (( $callHead == 1 )) && ! [[ "$type" == "string" || "$type" == "integer" ]]
					then
						$type.${callStack[$callHead]} "${@:2}"
					else
						value=$(this="$value" $type.${callStack[$callHead]} "${@:2}")
					fi
					# fi

					# save output for next call
					callHead+=1
				done

				if [[ -n ${value+isSet} ]]
				then
					echo "${value}"
				fi
			fi

			#subject="complex" Log "Invoke type: $type, object: $rootObject, ${child:+child: $child, }${bracketOperator:+"$bracketOperator: $bracketParam, "}operator: $operator${parameter:+, param $parameter}"
			
			#$type${child:+".$child"} "${@:2}"
		else
			return 1
		fi
	fi
	# if callOperator then for sure an object - check if exists, else error
	
}
# # command_not_found_handle() {
# Exception.CustomCommandHandler() {
# 	subject="command" Log "Invoking $1"
# 	# if is resolvable immediately
# 	if [[ ! "$1" =~ \. ]] && [[ -n ${!1+isSet} ]]
# 	then
# 		# check if an object UUID
# 		# else print var
# 		subject="builtin" Log "Invoke builtin getter"
# 		# echo "var $1=${!1}"
# 		echo "${!1}"
# 	else
# 		local splitParamRegex='([^=+/\\\*~:-]+)([=+/\\\*~:-])?(.*)'
# 		local -a varDetails
# 		this="$1" bracketParam=0 string.matchGroups "$splitParamRegex" varDetails

# 		local varName="${varDetails[1]}"
# 		local operator="${varDetails[2]}"
# 		local parameter="${varDetails[3]}"

# 		local -a varDetails=( )
# 		local splitBracketRegex='([a-zA-Z0-9_]+)+([[{][^.]*[]}])*' #([a-zA-Z0-9_]+)+
# 		this="$1" bracketParam=@ string.matchGroups "$splitBracketRegex" varDetails

# 		local -a methodList
# 		local -a methodParamsToParse

# 		local -n this="varDetails" 
# 			array.takeEvery 3 1 methodList
# 			array.takeEvery 3 2 methodParamsToParse
# 		unset -n this

# 		subject="complex" Log "Will make an object call: ${methodList[*]}"

# 		if [[ "${methodParamsToParse[*]}" == *'['* || "${methodParamsToParse[*]}" == *'{'* ]]
# 		then

# 			local -n this="methodParamsToParse" 
# 				#array.forEach param 'echo test: $method'
# 				local paramsList=$(array.last)
# 			unset -n this

# 			local -a bracketDetails
# 			local bracketDetailsRegex='[[]([^]]*)[]]'
# 			this="$paramsList" bracketParam=@ string.matchGroups "$bracketDetailsRegex" bracketDetails

# 			local -a bracketParam

# 			local -n this="bracketDetails" 
# 				array.takeEvery 2 1 bracketParam
# 			unset -n this

# 			subject="complex" Log "Last Object Params: ${bracketParam[*]}"

# 		fi

#     	local rootObject=${varName%%.*} # strip . maybe better to use methodList[0] ?
#     	[[ $rootObject == $varName ]] || child=${methodList[1]}
		
# 		# if is resolvable immediately
# 		local rootObjectResolvable=$rootObject[@]
#     	if [[ -n ${!rootObjectResolvable+isSet} ]]
# 		then
# 			local typeInfo="$(declare -p $rootObject)"

# 			# first dereferrence
# 			if [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
# 			then
# 				rootObject=${BASH_REMATCH[1]}
# 				typeInfo="$(declare -p $rootObject)"
# 			fi

# 			if [[ "$typeInfo" == "declare -a"* ]]
# 			then
# 				local type=array
# 			elif [[ "$typeInfo" == "declare -A"* ]]
# 			then
# 				local type=dictionary
# 			elif [[ "$typeInfo" == "declare -i"* ]]
# 			then
# 				local type=integer
# 			else
# 				local type=string
# 			fi

# 			subject="complex" Log "Invoke type: $type, object: $rootObject, ${child:+child: $child, }${bracketOperator:+"$bracketOperator: $bracketParam, "}operator: $operator${parameter:+, param $parameter}"
# 			local -n this="$rootObject"
# 			$type${child:+".$child"} "${@:2}"
# 		else
# 			return 1
# 		fi
# 	fi
# }

testFunc() {
	# local testing="onething.object['abc def'].length[123].something[2]{another}"
	#local testing="something.somethingElse{var1,var2,var3}[a].extensive{param1 : + can be =\"anything \"YO # -yo space}{another}[0][2]=LALALA} and what if=we have.an equals.test[immi]{lol}?"
	local something="haha haha Yo!"
	local testing="something.sanitized{}.length{}"
	# local -a dupa
	# dupa~=something.toArray -- use dupa as output parameter/ret-val
	#local regex='(?:^|\.)([a-zA-Z0-9_]+)((?:{.*?})*)((?:\[.*?\])*)(?:(=|\+|/|\\|\*|~|:|-|\+=|-=|\*=|/=|==)(.*))*'
	local regex='(^|\.)([a-zA-Z0-9_]+)(({[^}]*})*)((\[[^]]*\])*)((\+=|-=|\*=|/=|==|\+\+|~=|:=|=|\+|/|\\|\*|~|:|-)(.*))*'

	local -a matches
	local -n return=matches
	this="$testing" bracketParam=@ string.matchGroups "$regex"
	# @ matches.forEach match 'this[$index]="$index: $match"'
	unset -n return

	local -a callStack
	local -a callStackParams
	local -a callStackLastParam
	local -a callStackBrackets
	local -a callStackLastBracket
	local callOperator="${matches[-2]}"
	local callValue="${matches[-1]}"

	local -n this="matches"
		local -n return=callStack; array.takeEvery 10 2; unset -n return
		local -n return=callStackParams; array.takeEvery 10 3; unset -n return
		local -n return=callStackLastParam; array.takeEvery 10 4; unset -n return
		local -n return=callStackBrackets; array.takeEvery 10 5; unset -n return
		local -n return=callStackLastBracket; array.takeEvery 10 6; unset -n return
	unset -n this

	local -n this="callStack"
		echo callStack:
		array.print
	unset -n this

	local -n this="callStackParams"
		echo callStackParams:
		array.print
	unset -n this
	
	local -n this="callStackBrackets"
		echo callStackBrackets:
		array.print
	unset -n this

	echo callOperator: $callOperator
	echo callValue: $callValue
	echo

	local -i callLength=$((${#callStack[@]} - 1))
	local -i callHead=1

	echo callLength: $callLength

	local rootObject="${callStack[0]}"

	# check for existance of $callStack[0] and whether it is an object
	# if is resolvable immediately
	local rootObjectResolvable=$rootObject[@]
	if [[ -n ${!rootObjectResolvable+isSet} ]]
	then
		local typeInfo="$(declare -p $rootObject)"

		# first dereferrence
		# maybe this should be "while" for recursive dereferrence?
		if [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
		then
			rootObject=${BASH_REMATCH[1]}
			typeInfo="$(declare -p $rootObject)"
		fi

		if [[ "$typeInfo" == "declare -a"* ]]
		then
			local type=array
			local -n this="$rootObject"
		elif [[ "$typeInfo" == "declare -A"* ]]
		then
			local type=dictionary
			local -n this="$rootObject"
		elif [[ "$typeInfo" == "declare -i"* ]]
		then
			local type=integer
			local value="${!rootObject}"
		elif [[ "${!rootObject}" == "$obj:"* ]]
		then
			# pass the rest of the call stack to the object invoker
			Object.Invoke "${!rootObject}" "${@:2}"
			return 0
		else
			local type=string
			local value="${!rootObject}"
		fi

		if (( $callLength == 1 )) && [[ -n "$callOperator" ]]
		then
			$type.$callOperator "$callValue" "${@:2}"
		else
			while ((callLength--))
			do
				echo calling: $type.${callStack[$callHead]}
				# does the method exist?
				if ! Function.Exists $type.${callStack[$callHead]}
				then
					e="Method: $type.${callStack[$callHead]} does not exist." skipBacktraceCount=4 thorw
				fi

				local -a mustacheParams=()
				local mustacheParamsRegex='[^{}]+'
				local -n return=mustacheParams; this="${callStackParams[$callHead]}" bracketParam=@ string.matchGroups "$mustacheParamsRegex"; unset -n return

				local -a brackets=()
				local bracketRegex='[^[]]+'
				local -n return=brackets; this="${callStackBrackets[$callHead]}" bracketParam=@ string.matchGroups "$bracketRegex" brackets; unset -n return

				echo brackets: ${brackets[*]} #${callStackParams[$callHead]}
				echo mustacheParams: ${mustacheParams[*]} #${callStackBrackets[$callHead]}
				echo --

				# if (( $callLength == 1 )) && [[ -n "$callOperator" ]]
				# then
				if (( $callHead == 1 )) && ! [[ "$type" == "string" || "$type" == "integer" ]]
				then
					$type.${callStack[$callHead]} "${@:2}"
				else
					value=$(this="$value" $type.${callStack[$callHead]} "${@:2}")
				fi
				# fi

				# save output for next call
				callHead+=1
			done

			if [[ -n ${value+isSet} ]]
			then
				echo "${value}"
			fi
		fi

		#subject="complex" Log "Invoke type: $type, object: $rootObject, ${child:+child: $child, }${bracketOperator:+"$bracketOperator: $bracketParam, "}operator: $operator${parameter:+, param $parameter}"
		
		#$type${child:+".$child"} "${@:2}"
	else
		return 1
	fi

	# if callOperator then for sure an object - check if exists, else error
	

}

# testFunc

testFunc2() {
	local something="haha haha Yo!"
	something
	something.sanitized{}.length{}.length{}.legnth{}
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
