#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

namespace seamless

Log.AddOutput seamless CUSTOM

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
    
    #__typeCreate_OLDIFS=$IFS
    #IFS=$__oo__originalIFS
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

string.length() {
	echo ${#this}
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
	@var regex
	@reference matchGroups
	@var returnMatch="${bracketParam[0]}"

	local -i matchNo=0
	local string="$this"
	while [[ "$string" =~ $regex ]]
	do
		subject="regex" Log "match $matchNo: ${BASH_REMATCH[*]}"

		if [[ "$returnMatch" == "@" || $matchNo -eq "$returnMatch" ]]
		then
			matchGroups+=( "${BASH_REMATCH[@]}" )
			[[ "$returnMatch" == "@" ]] || return 0
		fi
		# cut out the match so we may continue
		string="${string/"${BASH_REMATCH[0]}"}" # "
		matchNo+=1
	done
}

array.takeEvery() {
	@int every
	@int startingIndex
	@reference outputArray

	local -i count=0

	local index
	for index in "${!this[@]}"
	do
		if [[ $index -eq $(( $every * $count + $startingIndex )) ]]
		then
			#echo "$index: ${this[$index]}"
			outputArray+=( "${this[$index]}" )
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
# command_not_found_handle() {
Exception.CustomCommandHandler() {
	subject="command" Log "Invoking $1"
	# if is resolvable immediately
	if [[ ! "$1" =~ \. ]] && [[ -n ${!1+isSet} ]]
	then
		# check if an object UUID
		# else print var
		subject="builtin" Log "Invoke builtin getter"
		# echo "var $1=${!1}"
		echo "${!1}"
	else
		local splitParamRegex='([^=+/\\\*~:-]+)([=+/\\\*~:-])?(.*)'
		local -a varDetails
		this="$1" bracketParam=0 string.matchGroups "$splitParamRegex" varDetails

		local varName="${varDetails[1]}"
		local operator="${varDetails[2]}"
		local parameter="${varDetails[3]}"

		local -a varDetails=( )
		local splitBracketRegex='([a-zA-Z0-9_]+)+([[{][^.]*[]}])*' #([a-zA-Z0-9_]+)+
		this="$1" bracketParam=@ string.matchGroups "$splitBracketRegex" varDetails

		local -a methodList
		local -a methodParamsToParse

		local -n this="varDetails" 
			array.takeEvery 3 1 methodList
			array.takeEvery 3 2 methodParamsToParse
		unset -n this

		subject="complex" Log "Will make an object call: ${methodList[*]}"

		if [[ "${methodParamsToParse[*]}" == *'['* || "${methodParamsToParse[*]}" == *'{'* ]]
		then

			local -n this="methodParamsToParse" 
				#array.forEach param 'echo test: $method'
				local paramsList=$(array.last)
			unset -n this

			local -a bracketDetails
			local bracketDetailsRegex='[[]([^]]*)[]]'
			this="$paramsList" bracketParam=@ string.matchGroups "$bracketDetailsRegex" bracketDetails

			local -a bracketParam

			local -n this="bracketDetails" 
				array.takeEvery 2 1 bracketParam
			unset -n this

			subject="complex" Log "Last Object Params: ${bracketParam[*]}"

		fi

    	local rootObject=${varName%%.*} # strip . maybe better to use methodList[0] ?
    	[[ $rootObject == $varName ]] || child=${methodList[1]}
		
		# if is resolvable immediately
		local rootObjectResolvable=$rootObject[@]
    	if [[ -n ${!rootObjectResolvable+isSet} ]]
		then
			local typeInfo="$(declare -p $rootObject)"

			# first dereferrence
			if [[ "$typeInfo" =~ "declare -n" ]] && [[ "$typeInfo" =~ \"([a-zA-Z0-9_]*)\" ]]
			then
				rootObject=${BASH_REMATCH[1]}
				typeInfo="$(declare -p $rootObject)"
			fi

			if [[ "$typeInfo" == "declare -a"* ]]
			then
				local type=array
			elif [[ "$typeInfo" == "declare -A"* ]]
			then
				local type=dictionary
			elif [[ "$typeInfo" == "declare -i"* ]]
			then
				local type=integer
			else
				local type=string
			fi

			subject="complex" Log "Invoke type: $type, object: $rootObject, ${child:+child: $child, }${bracketOperator:+"$bracketOperator: $bracketParam, "}operator: $operator${parameter:+, param $parameter}"
			local -n this="$rootObject"
			$type${child:+".$child"} "${@:2}"
		else
			return 1
		fi
	fi
}

testFunc() {
	var hello=somevalue
	var makownik=makownikowiec
	local normalVar="yo yoo yoo1"
	local -i normalInt=1
	local -A object=( [abc]=$obj:dupa )

	#Advanced kopsik # initialize string kopsik with a unique ID refering to the object
	#dictionary somedic=([one]=something [two]=somethingElse)

	normalVar
	local group=1
	local match=1
	normalVar.match[$group][$match] "(y[o1]*)"
	# normalVar.match "(y[o1]*)" 1 0
	normalVar.length
	normalVar.match[$group][$match]{"(y[o1]*)"}.length
	normalVar.sanitized.length
	@ normalVar.change
	normalVar

	local testing="onething.object['abc def'].length[123].something"
	# testing.match "([a-zA-Z0-9_]+)\[['\"]*([^]'\"]+)['\"]*\]" 0 @ #"\[([^\]]*)\]"
	#local output="$(testing.match "([a-zA-Z0-9_]+)+(\[['\"]*([^]'\"]+)['\"]*\])*" 3 @)"
	local output #="$(echo -e "\ntwo\n\nfour\nfive\n\n")"
	printf -v output "\n\ntwo\n\nfour\nfive\n\n"
	local -a matches
	@ output.toArray matches
	@ matches.forEach match 'declare -p match'
	@ matches.forEach match 'this[$index]="test $match"'
	# @ matches.forEach match 'match="test $match"; echo $match'
	matches.print
	# matches.print

	# this="$output" string.toArray
	# echo 0: ${matches[0]}
	# echo 1: ${matches[1]}

	# object[abc].length

	# hello
	# makownik
	# normalVar
	# normalInt++
	# object
	# object.subObject.tralala
	# object.subObject.tralalaInt[something]
	# object.subObject.tralalaInt[something]--
	# object[abc]
	# normalInt*dupa
	#someError.blabla

}

testFunc


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
