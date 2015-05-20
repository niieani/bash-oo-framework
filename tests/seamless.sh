#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

namespace seamless

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

    	Console.WriteStdErr "$__typeCreate_varName ($__typeCreate_varType)"
    	
    	eval "$__typeCreate_varName(){
    		#GC.Run
    		#__oo__garbageCollector+=( ${FUNCNAME[*]:1}/$__typeCreate_varName )

    		if [[ \" \${FUNCNAME[*]} \" != *' ${FUNCNAME[1]} '* ]]
			then
				# lazy garbage collecting
				echo collecting garbage
				unset $__typeCreate_varName
				# TODO: unset everything under $__typeCreate_varName.*
				throw 'Object \"$__typeCreate_varName\" is out of scope'
    		fi
	    	echo I am $__typeCreate_varType with value: \$$__typeCreate_varName
	    	$__typeCreate_varName+=_suffix
	    }"

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


Exception.CustomCommandHandler() {
    :
}

testFunc() {
	var hello=somevalue
	var makownik=makownikowiec
	#Advanced kopsik # initialize string kopsik with a unique ID refering to the object
	#dictionary somedic=([one]=something [two]=somethingElse)

	echo Inside Test Func
	hello
	makownik

	echo $hello _ $makownik
	# echo functions "${FUNCNAME[@]}"
	declare -n
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

String.GetRandomAlphanumeric() {
    # http://stackoverflow.com/a/23837814/595157
    local chars=( {a..z} {A..Z} {0..9} )
    local length=$1
    local ret=
    while((length--)); do
        ret+=${chars[$((RANDOM%${#chars[@]}))]}
    done
    printf '%s\n' "$ret"
}