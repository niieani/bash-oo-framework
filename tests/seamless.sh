#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

namespace seamless

Log.AddOutput seamless INFO

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

Command.StripOperator() {
	local varName="$1"
	local operator
	local parameter
	varName="${varName%%+*}" #strip plus
	[[ "$varName" == "$1" ]] || { operator=+; parameter=${1#*+}; echo ${varName} ${operator} "${parameter}"; return; }
	varName="${varName%%-*}" #strip minus
	[[ "$varName" == "$1" ]] || { operator=-; parameter=${1#*-}; echo ${varName} ${operator} "${parameter}"; return; }
	varName="${varName%%\**}" #strip asterisk
	[[ "$varName" == "$1" ]] || { operator='asterisk'; parameter=${1#*\*}; echo "${varName}" "${operator}" "${parameter}"; return; }
	varName="${varName%%/*}" #strip slash
	[[ "$varName" == "$1" ]] || { operator=/; parameter=${1#*/}; echo ${varName} ${operator} "${parameter}"; return; }
	varName="${varName%%~*}" #strip ~
	[[ "$varName" == "$1" ]] || { operator=~; parameter=${1#*+}; echo ${varName} ${operator} "${parameter}"; return; }
	varName="${varName%%:*}" #strip :
	[[ "$varName" == "$1" ]] || { operator=:; parameter=${1#*+}; echo ${varName} ${operator} "${parameter}"; return; }
	echo "$varName" "default" ""
}

Command.StripBrackets() {
	local varName=$1
	local operator
	local parameter
	varName="${varName%%[*}" #strip [
	[[ "$varName" == "$1" ]] || { operator=[]; parameter=${1#*[}; parameter=${parameter%*]}; echo ${varName} ${operator} "${parameter}"; return; }
	varName="${varName%%{*}" #strip {
	[[ "$varName" == "$1" ]] || { operator={}; parameter=${1#*{}; parameter=${parameter%*\}}; echo ${varName} ${operator} "${parameter}"; return; }

	echo "$varName" "" ""
}

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

string.match() {
	@var regex
	@int capturingGroup #bracketParam

	local string="$this"
	# \[([^\]]*)\]
	while [[ "$string" =~ $regex ]]
	do
		subject="regex" Log "${BASH_REMATCH[*]} @ ${capturingGroup}"
		echo "${BASH_REMATCH[$capturingGroup]}"
		string="${string/"${BASH_REMATCH[0]}"}" # "
	done
}

Exception.CustomCommandHandler() {
	subject="builtin" Log "Invoking $1"
	# if is resolvable immediately
	if [[ ! "$1" =~ \. ]] && [[ -n ${!1+isSet} ]]
	then
		# check if an object UUID
		# else print var
		subject="builtin" Log "Invoke builtin getter"
		# echo "var $1=${!1}"
		echo "${!1}"
	else
		local varDetails=( $(Command.StripOperator $1) )
		local varName="${varDetails[0]}"
		local operator="${varDetails[1]}"
		local parameter="${varDetails[*]:2}"

		local varBrackets=( $(Command.StripBrackets $varName) )
		varName="${varBrackets[0]}"
		local bracketOperator="${varBrackets[1]}"
		local bracketParam="${varBrackets[*]:2}" # TODO: support multiple spaces in parameters

    	local rootObject=${varName%%.*} #strip .
    	[[ $rootObject == $varName ]] || child=${varName#*.}
		
		# if is resolvable immediately
		#declare -p ${rootObject}
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
			#self="$rootObject" ${child:+"child=$child"} ${bracketOperator:+"bracketOperator=$bracketOperator"} ${bracketParam:+"bracketParam=$bracketParam"} operator="$operator" ${parameter:+"parameter=$parameter"} 
			$type.$child "${@:2}"
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
	normalVar.length
	normalVar.sanitized
	normalVar.match "(y[o1]*)" 1
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
