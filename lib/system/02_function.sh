Function.Exists(){
    local name="$1"
    local typeMatch=$(type "$name" 2> /dev/null) || return 1
    echo "$typeMatch" | grep "function\|alias" &> /dev/null || return 1
    return 0
}
alias Object.Exists="Function.Exists"

Function.AssignParamsLocally(){
    ## unset first miss
    unset '__oo__params[0]'

    ## TODO: if no params were defined, we can add ternary operator and others
    # __oo__functionsTernaryOperator+=( ${FUNCNAME[1]} )

    declare -i i
    local iparam
    local variable
    local type
    local optional=false
    for i in "${!__oo__params[@]}"
    do
        Log.Debug 4 "i    : $i"

        iparam=$i

        ### TODO: variable might be optional, in this case we test if it has '=' sign and split it
        ### then we assign a variable optional=true and only require input for those that aren't optional

        variable="${__oo__params[$i]}"
        Log.Debug 4 "var  : ${__oo__params[$i]}"

        i+=-1

        type="${__oo__param_types[$i]}"
        Log.Debug 4 "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct
        # test if the types are right, if not, add note and "read" to wait for user input
        # assign correct values approprietly so they are avail later on

        if [[ $type = 'params' ]]; then
            for _x in "${!__oo__params[@]}"
            do
                Log.Debug 4 "we are params so we shift"
                [[ "${__oo__param_types[$_x]}" != 'params' ]] && eval shift
            done
            eval "$variable=\"\$@\""
        else
            ## assign value ##
            ## TODO: support different types

            Log.Debug 4 "value: ${!iparam}"
            eval "$variable=\"\$$iparam\""
        fi
    done

    unset __oo__params
    unset __oo__param_types
}

alias Function.StashPreviousLocal="declare -a \"__oo__params+=( '\$_' )\""
alias @@verify="Function.StashPreviousLocal; Function.AssignParamsLocally \"\$@\"" # ; for i in \${!__oo__params[@]}; do
alias @params="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "
alias @mixed="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( mixed )\"; local "
alias :="eval"
