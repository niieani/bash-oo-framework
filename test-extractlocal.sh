#!/bin/bash
#rambo() {
##    case " ${!__oo__params*} " in
##        *" __oo__params "*) declare -a "__oo__params+=( \"$(declare -p | grep 'declare -- ' | tail -1 | cut -d " " -f 3)\" )";;
##        *) declare -a __oo__params;;
##    esac
#
#    declare -a "__oo__params+=( \"$(declare -p | grep 'declare -- ' | tail -1 | cut -d " " -f 3)\" )"
#    declare -a "__oo__param_types+=( rambo )"
#
#    local kiki
#
#    declare -a "__oo__params+=( \"$(declare -p | grep 'declare -- ' | tail -1 | cut -d " " -f 3)\" )"
#    declare -a "__oo__param_types+=( rambo )"
#    local mimi
#
#    declare -a "__oo__params+=( \"$(declare -p | grep 'declare -- ' | tail -1 | cut -d " " -f 3)\" )"
#    unset __oo__params[0]
#
#    #local secondDeclare="$(declare -p | grep 'declare -- ' | tail -1)"
#    #local secondDeclare="$(declare -p | grep 'declare --' | grep -v 'declare -- _=' | grep -v 'declare -- firstDeclare=' | sort)"
#    (
#        IFS=$'\n'
#        echo "${__oo__params[*]}"
#        echo "${__oo__param_types[*]}"
#    )
#}
#
#rambo

shopt -s expand_aliases
#alias declareType='declare -a "__oo__param_types+=( TYPE )"'
#alias var="declare -A \"__oo__params+=( [\"\$(declare -p | grep 'declare -- ' | tail -1 | cut -d ' ' -f 3)\"]=\"TYPE\" )\"; local "

#alias var="declare -A \"__oo__params+=( [key]=\"TYPE\" )\"; local "

oo:assignParamsToLocal() {
    ## add last one
#    declare -a "__oo__params+=( $(declare -p | grep 'declare -- ' | tail -1 | cut -d ' ' -f 3) )"
    ## unset first miss
    unset __oo__params[0]
    declare -i i
    local iparam
    local variable
    local type
    for i in "${!__oo__params[@]}"
    do
        echo "i    : $i"

        iparam=$i

        variable="${__oo__params[$i]}"
        echo "var  : ${__oo__params[$i]}"

        i+=-1
        type="${__oo__param_types[$i]}"
        echo "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct

#        eval "$variable=\"${!iparam}\""
        eval "$variable=\"\$$iparam\""
    done

#    local variable
#    declare -i i=0
#    declare -a varList
#    declare -a typeList
#    for variable in "${!__oo__params[@]}"
#    do
#        echo "i    : $i"
#        echo "var  : $variable"
#        echo "type : ${__oo__params[$variable]}"
#        echo
#        i+=1
#    done

#    (
#        IFS=$'\n'
#        echo "${__oo__params[*]}"
#    )
}

#alias thefinish="declare -A \"__oo__params+=( [\"\$(declare -p | grep 'declare -- ' | tail -1 | cut -d ' ' -f 3)\"]=\"__END__\" )\"; finish" #; unset __oo__params[0]
alias oo:stashPreviousLocal="declare -a \"__oo__params+=( \$(declare -p | grep 'declare -- ' | tail -1 | cut -d ' ' -f 3) )\""
alias @var="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( TYPE )\"; local "
alias @@verify="oo:stashPreviousLocal; oo:assignParamsToLocal"

bambo() {
    @var test1
    @var test2
    @@verify "$@"

    echo here is first: "$test1"
    echo here is 2nd: "$test2"
}

bambo "value of one" valueOf2
