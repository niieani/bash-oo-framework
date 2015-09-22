namespace oo

Function.AssignParamLocally() {
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
        __assign_next=true
        subject="parameters-assign" Log "Will assign next one"

        local nextAssignment=$(( ${__assign_paramNo:-0} + 1 ))
        if [[ "${!nextAssignment}" == "$ref:"* ]]
        then
            subject="parameters-reference" Log "next param is an object reference: $nextAssignment"
            __assign_isReference="-n"
        else
            __assign_isReference=""
        fi
        return 0
    fi

    local varDeclaration="${commandWithArgs[*]:1}"
    if [[ $varDeclaration == '-'* || $varDeclaration == '${'* ]]
    then
        varDeclaration="${commandWithArgs[*]:2}"
    fi
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"
    # TODO: checking for parameter existance or default value

    if [[ ! -z $__assign_varType ]]
    then
        subject="parameters-setting" Log "SETTING: $__assign_varName = \$$__assign_paramNo"
        # subject="parameters-setting" Log --

        local execute

        if [[ "$__assign_varType" == "array" ]]
        then
            # passing array:
            execute="$__assign_varName=( \"\${@:$__assign_paramNo:$__assign_arrLength}\" )"
            eval "$execute"
            __assign_paramNo+=$(($__assign_arrLength - 1))

            unset __assign_arrLength
        elif [[ "$__assign_varType" == "params" ]]
        then
            execute="$__assign_varName=( \"\${@:$__assign_paramNo}\" )"
            eval "$execute"
        elif [[ "$__assign_varType" == "reference" || ! -z "${!__assign_paramNo}" ]]
        then
            if [[ "${!__assign_paramNo}" == "$ref:"* ]]
            then
                local refVarName="${!__assign_paramNo#$ref:}"
                execute="$__assign_varName=$refVarName"
            else
                # escape $__assign_paramNo with \"
                # local escapedAssignment="${!__assign_paramNo}"
                # escapedAssignment="${escapedAssignment//\"/\\\"}"
                # execute="$__assign_varName=\"$escapedAssignment\""
                execute="$__assign_varName=\"\$$__assign_paramNo\""
            fi

            subject="parameters-executing" Log "EXECUTING: $execute"
            eval "$execute"
        fi
        unset __assign_varType
        unset __assign_isReference
    fi

    if [[ "$command" != "local" || "$__assign_next" != "true" ]]
    then
        __assign_normalCodeStarted+=1

        subject="parameters-nopass" Log "NOPASS ${commandWithArgs[*]}"
        subject="parameters-nopass" Log "normal code count ($__assign_normalCodeStarted)"
        # subject="parameters-nopass" Log --
    else
        unset __assign_next

        __assign_normalCodeStarted=0
        __assign_varName="$varName"
        __assign_varType="$__capture_type"
        __assign_arrLength="$__capture_arrLength"

        subject="parameters-pass" Log "PASS ${commandWithArgs[*]}"
        # subject="parameters-pass" Log --

        __assign_paramNo+=1
    fi
}

Function.CaptureParams() {
    subject="parameters" Log "Capturing Type $_type"
    # subject="parameters" Log --

    __capture_type="$_type"
    __capture_arrLength="$l"
}
    
# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias @trapAssign='Function.CaptureParams; declare -i __assign_normalCodeStarted=0; trap "declare -i __assign_paramNo; Function.AssignParamLocally \"\$BASH_COMMAND\" \"\$@\"; [[ \$__assign_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __assign_varType && unset __assign_varName && unset __assign_paramNo" DEBUG; true; true; '
alias @param='@trapAssign local'
alias @reference='_type=reference @trapAssign local -n'
alias @var="_type=var @trapAssign local \${__assign_isReference}"
alias @int='_type=int @trapAssign local -i'
alias @params='_type=params @param'
alias @array='_type=array @param'
alias @array[2]='l=2 _type=array @param'
alias @array[3]='l=3 _type=array @param'
alias @array[4]='l=4 _type=array @param'
alias @array[5]='l=5 _type=array @param'
alias @array[6]='l=6 _type=array @param'
alias @array[7]='l=7 _type=array @param'
alias @array[8]='l=8 _type=array @param'
alias @array[9]='l=9 _type=array @param'
alias @array[10]='l=10 _type=array @param'

declare -g ref=$'\UEFF1A'$'\UEFF1A'
