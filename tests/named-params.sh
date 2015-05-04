#!/usr/bin/env bash

#Function.AssignParamsLocally(){
#    ## unset first miss
#    unset '__oo__params[0]'
#
#    ## TODO: if no params were defined, we can add ternary operator and others
#    # __oo__functionsTernaryOperator+=( ${FUNCNAME[1]} )
#
#    declare -i i
#    local iparam
#    local variable
#    local type
#    local optional=false
#    for i in "${!__oo__params[@]}"
#    do
#        Log.Debug 4 "i    : $i"
#
#        iparam=$i
#
#        ### TODO: variable might be optional, in this case we test if it has '=' sign and split it
#        ### then we assign a variable optional=true and only require input for those that aren't optional
#
#        variable="${__oo__params[$i]}"
#        Log.Debug 4 "var  : ${__oo__params[$i]}"
#
#        i+=-1
#
#        type="${__oo__param_types[$i]}"
#        Log.Debug 4 "type : ${__oo__param_types[$i]}"
#
#        ### TODO: check if type is correct
#        # test if the types are right, if not, add note and "read" to wait for user input
#        # assign correct values approprietly so they are avail later on
#
#        if [[ $type = 'params' ]]; then
#            for _x in "${!__oo__params[@]}"
#            do
#                Log.Debug 4 "we are params so we shift"
#                [[ "${__oo__param_types[$_x]}" != 'params' ]] && eval shift
#            done
#            eval "$variable=\"\$@\""
#        else
#            ## assign value ##
#            ## TODO: support different types
#
#            Log.Debug 4 "value: ${!iparam}"
#            eval "$variable=\"\$$iparam\""
#        fi
#    done
#
#    unset __oo__params
#    unset __oo__param_types
#}
#
#alias Function.StashPreviousLocal="declare -a \"__oo__params+=( '\$_' )\""
#alias @@map="Function.StashPreviousLocal; Function.AssignParamsLocally \"\$@\"" # ; for i in \${!__oo__params[@]}; do
#alias @params="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "
#alias @var="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( mixed )\"; local "

set -o errtrace
shopt -s expand_aliases
set -o pipefail

#[[ "$finito" = true ]] && echo FINITO || [[ "$finito" != true ]] &&

# with a post trap: alias @var='trap "declare -i \"paramNo+=1\"; assignNamedParam \"mixed\" \"\$BASH_COMMAND\" \"\$@\"; trap \"echo postTrap; trap - DEBUG\" DEBUG" DEBUG; local '

#declare assignVarType
#declare assignVarName
#declare assignNormalCodeStarted
#alias @var='trap "declare -i \"paramNo+=1\"; assignNamedParam \"mixed\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
#alias @params='trap "declare -i \"paramNo+=1\"; assignNamedParam \"params\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
#alias @array='capture__capture_arrLength; trap "declare -i \"paramNo+=1\"; assignNamedParam \"array\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '

alias @param='capture; trap "declare -i \"paramNo+=1\"; assignNamedParam \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
alias @var='_type=mixed @param'
alias @params='_type=params @param'
alias @array='_type=array @param'

#alias @var='@array'
#alias @params='@array'
#alias @array[3]='trap "declare -i \"paramNo+=1\"; assignNamedParam \"array 2\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
#alias @array[4]='trap "declare -i \"paramNo+=1\"; assignNamedParam \"array 2\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
#alias @array[5]='trap "declare -i \"paramNo+=1\"; assignNamedParam \"array 2\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '
#alias @array[6]='trap "declare -i \"paramNo+=1\"; assignNamedParam \"array 2\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$assignNormalCodeStarted = true ]] && trap - DEBUG && unset assignVarType && unset assignVarName && unset assignNormalCodeStarted && unset paramNo" DEBUG; local '


#alias @var='trap "declare -i \"paramNo+=1\"; assignNamedParam \"mixed\" \"\$BASH_COMMAND\" \"\$@\"; [[ \$doubleTrapExecuted = true ]] && trap - DEBUG; doubleTrapExecuted=true" DEBUG; local '
#alias @var='trap "trap - DEBUG" DEBUG; local'
#assignedName() {
#    assignedName="$*"
#}

#capture__capture_arrLength() {
#    __capture_arrLength=$l
#}

capture() {
    __capture_type="$_type"
    __capture_arrLength="$l"
}

testHere() {
    @var hello
    @var opiciarka
    @var nothing=default
    l=4 @array theArr
    l=2 @array anotherArray
    @params theparams

    echo Final result: $hello $opiciarka $nothing
    echo Array: ${theArr[@]}
    echo Array 3: ${theArr[2]}
    echo AnotherArr: ${anotherArray[@]}
    echo Params: ${theparams[@]}
#    echo Param 2: ${theparams[1]}
#    echo The trap should be unset
#    echo Another
#    storage[test]=changed
#    echo Inside storage: ${storage[test]}
#    echo $paramNo
#    echo OtherCommand $finito
}

another() {
    @var hello
    @var wtf=wtf
    @var hill=default

    echo Final result: $hello $wtf $hill
    echo
}

#declare assignVarType
#declare assignVarName
#declare assignNormalCodeStarted

assignNamedParam() {

#    local varType="$1"
    local commandWithArgs=( $1 )
    local command="${commandWithArgs[0]}"

    shift

#    echo "$__capture_type"
#    if [[ "$command" == "l="* ]]
#    then
#        echo capture__capture_arrLength
#        return 0
#    fi

    if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* ]]
    then
        paramNo+=-1
        return 0
    fi

    if [[ "$command" != "local" ]]
    then
        assignNormalCodeStarted=true
    fi

    local varDeclaration="${commandWithArgs[1]}"
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"

#    echo Type \"$varType\"
#    echo Command \"${commandWithArgs[*]}\"
#    echo VarName \"$varName\" = $varValue
##    echo Params \"$*\"
#    echo Param[\"$paramNo\"] = ${!paramNo}
#    echo -------

    if [[ ! -z $assignVarType ]]
    then
        local previousParamNo=$(expr $paramNo - 1)
#        echo Executing previous $previousParamNo

#        echo $assignVarType

        if [[ "$assignVarType" == "array" ]]
        then
#            local __capture_arrLength="$assign__capture_arrLength"

            echo length: $assign__capture_arrLength
#            local __capture_arrLength="${assignVarType%=*}"
            # passing array:
#            execute="$assignVarName=( \"\${$previousParamNo[@]}\" )"
            execute="$assignVarName=( \"\${@:$previousParamNo:$assign__capture_arrLength}\" )"
#            echo "$execute"
            eval "$execute"
            paramNo+=$(expr $assign__capture_arrLength - 1)

            unset assign__capture_arrLength

        elif [[ "$assignVarType" == "params" ]]
        then
            #echo params
            execute="$assignVarName=( \"\${@:$previousParamNo}\" )"
            eval "$execute"
        #${a[@]:1}
        elif [[ ! -z "${!previousParamNo}" ]]
        then
            execute="$assignVarName=\"\$$previousParamNo\""
            #echo "$execute"
            eval "$execute"
#            echo -------
        fi
    fi

#    assignVarType="$varType"
    assignVarType="$__capture_type"
    assignVarName="$varName"
    assign__capture_arrLength="$__capture_arrLength"
}


declare -Ag storage
storage[test]=one
storage[papa]=two

anArray=( a b "c c" d )

testHere first second three "${anArray[@]}" five six params
another 1

#echo Outside result: $hello $opiciarka
#echo Outside storage: ${storage[test]}

#func() {
#    tata=true
#    echo $tata
#    local tata
#    echo $tata
#}
#
#func