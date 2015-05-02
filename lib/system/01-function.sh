Function.Exists(){
    local fullMethodName="$1"
    #echo checking method $fullMethodName
    # http://stackoverflow.com/questions/511683/bash-get-list-of-commands-starting-with-a-given-string
    local compgenFunctions=($(compgen -A 'function' "$fullMethodName"))
    local compgenAliases=($(compgen -A 'alias' "$fullMethodName"))
    ## TODO: add exact matching
    [[ ${#compgenFunctions[@]} -gt 0 ]] || [[ ${#compgenAliases[@]} -gt 0 ]] && return 0
    return 1
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
        Log.Debug:4 "i    : $i"

        iparam=$i

        ### TODO: variable might be optional, in this case we test if it has '=' sign and split it
        ### then we assign a variable optional=true and only require input for those that aren't optional

        variable="${__oo__params[$i]}"
        Log.Debug:4 "var  : ${__oo__params[$i]}"

        i+=-1

        type="${__oo__param_types[$i]}"
        Log.Debug:4 "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct
        # test if the types are right, if not, add note and "read" to wait for user input
        # assign correct values approprietly so they are avail later on

        if [[ $type = 'params' ]]; then
            for _x in "${!__oo__params[@]}"
            do
                Log.Debug:4 "oo: we are params so we shift"
                [[ "${__oo__param_types[$_x]}" != 'params' ]] && eval shift
            done
            eval "$variable=\"\$@\""
        #            $variable="$@"
        #            return
        else
            ## assign value ##

            Log.Debug:4 "value: ${!iparam}"
            #           eval "$variable=\"${!iparam}\""
            eval "$variable=\"\$$iparam\""
        fi
    done

    unset __oo__params
    unset __oo__param_types
}

alias oo:stashPreviousLocal="declare -a \"__oo__params+=( '\$_' )\""
alias @@verify="oo:stashPreviousLocal; Function.AssignParamsLocally \"\$@\"" # ; for i in \${!__oo__params[@]}; do
alias @params="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "
alias @mixed="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( mixed )\"; local "
alias :="eval"
#alias untrap="trap '' DEBUG"
#trap="declare -i trapCount && trapCount+=1 && test \$trapCount -gt \$paramCount && trap '' DEBUG && oo:stashPreviousLocal && Function.AssignParamsLocally \"\$@\""
#alias :="declare -i paramCount; paramCount+=1; trap \"$trap\" DEBUG; eval"
