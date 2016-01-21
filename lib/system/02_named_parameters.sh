namespace oo/type

# TODO: required parameters

Variable::TrapAssignNumberedParameter() {
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'
    
    local commandWithArgs=( $1 )
    local command="${commandWithArgs[0]}"

    shift

#    Log "TRAP: ${commandWithArgs[@]}"

    if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* || "$command" == "__capture_valueRequired="* || "$command" == "__capture_valueReadOnly="* ]]
    then
        return 0
    fi

    if [[ "${commandWithArgs[*]}" == "true" ]]
    then
        __assign_next=true
        DEBUG subject="parameters-assign" Log "Will assign next one"

        local nextAssignment=$(( ${__assign_paramNo:-0} + 1 ))
        if [[ "${!nextAssignment}" == "$ref:"* ]]
        then
            DEBUG subject="parameters-reference" Log "next param is an object reference: $nextAssignment"
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
        DEBUG subject="parameters-setting" Log "SETTING: $__assign_varName = \$$__assign_paramNo"
        # subject="parameters-setting" Log --
        
        if [[ "$__assign_valueRequired" == 'true' && -z "${!__assign_paramNo}" ]]
        then
          e="Value is required for the parameter [$__assign_varType] $__assign_varName ($__assign_paramNo)" throw
          return
        fi
        
        unset __assign_valueRequired __assign_valueReadOnly

        case "$__assign_varType" in
          'params')
            # passing array:
            eval "$__assign_varName=( \"\${@:$__assign_paramNo:$__assign_arrLength}\" )"

            __assign_paramNo+=$(($__assign_arrLength - 1))
            unset __assign_arrLength
          ;;
          'rest')
            eval "$__assign_varName=( \"\${@:$__assign_paramNo}\" )"
          ;;
          'boolean')
            DEBUG Log passed "${!__assign_paramNo}", default "${__assign_varValue}"
            if [[ ! -z "${!__assign_paramNo}" ]]
            then
              if [[ "${!__assign_paramNo}" == "${__primitive_extension_fingerprint__boolean}:"* ]]
              then
                __assign_varValue="${!__assign_paramNo}"
              elif [[ "${!__assign_paramNo}" == 'true' || "${!__assign_paramNo}" == 'false' ]]
              then
                __assign_varValue="${__primitive_extension_fingerprint__boolean}:${!__assign_paramNo}"
              else
                __assign_varValue="${__primitive_extension_fingerprint__boolean}:false"
              fi
            elif [[ "${__assign_varValue}" == 'true' || "${__assign_varValue}" == 'false' ]]
            then
              __assign_varValue="${__primitive_extension_fingerprint__boolean}:${__assign_varValue}"
            elif [[ "${__assign_varValue}" != "${__primitive_extension_fingerprint__boolean}:true" && "${__assign_varValue}" != "${__primitive_extension_fingerprint__boolean}:false" ]]
            then
              __assign_varValue="${__primitive_extension_fingerprint__boolean}:false"
            fi
            eval "$__assign_varName=\"${__assign_varValue}\""
          ;;
          'array'|'map')
            if [[ ! -z "${!__assign_paramNo}" ]]
            then
              eval "local -$(Variable::GetDeclarationFlagFromType '$__assign_varType') tempMap=\"\$$__assign_paramNo\""
              local index
              local value

              ## copy the array / map item by item
              for index in "${!tempMap[@]}"
              do
                eval "$__assign_varName[\$index]=\"\${tempMap[\$index]}\""
              done

              unset index value tempMap
            fi
          ;;
          *)
            if [[ "$__assign_varType" == "reference" || ! -z "${!__assign_paramNo}" ]]
            then
                if [[ "${!__assign_paramNo}" == "$ref:"* ]]
                then
                    local refVarName="${!__assign_paramNo#$ref:}"
                    eval "$__assign_varName=$refVarName"
                else
                    # escape $__assign_paramNo with \"
                    # local escapedAssignment="${!__assign_paramNo}"
                    # escapedAssignment="${escapedAssignment//\"/\\\"}"
                    # execute="$__assign_varName=\"$escapedAssignment\""
                    eval "$__assign_varName=\"\$$__assign_paramNo\""
                fi

                # DEBUG subject="parameters-executing" Log "EXECUTING: $execute"
            fi
          ;;
        esac

        unset __assign_varType
        unset __assign_isReference

        if [[ ! -z ${__oo__bootstrapped+x} ]] && declare -f 'Type::CreateHandlerFunction' &> /dev/null
        then
            Type::CreateHandlerFunction "$__assign_varName" 2> /dev/null || true
        fi
    fi

    if [[ "$command" != "local" || "$__assign_next" != "true" ]]
    then
        __assign_normalCodeStarted+=1

        DEBUG subject="parameters-nopass" Log "NOPASS ${commandWithArgs[*]}"
        DEBUG subject="parameters-nopass" Log "normal code count ($__assign_normalCodeStarted)"
        # subject="parameters-nopass" Log --
    else
        unset __assign_next

        __assign_normalCodeStarted=0
        __assign_varName="$varName"
        __assign_varValue="$varValue"
        __assign_varType="$__capture_type"
        __assign_arrLength="$__capture_arrLength"
        __assign_valueRequired="$__capture_valueRequired"
        __assign_valueReadOnly="$__capture_valueReadOnly"

        DEBUG subject="parameters-pass" Log "PASS ${commandWithArgs[*]}"
        # subject="parameters-pass" Log --

        __assign_paramNo+=1
    fi
}

Variable::InTrapCaptureParameters() {
    DEBUG subject="parameters" Log "Capturing Type $_type"
    # subject="parameters" Log --

    __capture_type="$_type"
    __capture_arrLength="$l"
}

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias Variable::TrapAssign='Variable::InTrapCaptureParameters; local -i __assign_normalCodeStarted=0; trap "declare -i __assign_paramNo; Variable::TrapAssignNumberedParameter \"\$BASH_COMMAND\" \"\$@\"; [[ \$__assign_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __assign_varType __assign_varName __assign_varValue __assign_paramNo __assign_valueRequired __assign_valueReadOnly" DEBUG; true; true; '
alias Variable::TrapAssignLocal='Variable::TrapAssign local'
alias [reference]='_type=reference Variable::TrapAssign local -n'
alias [string]="_type=string Variable::TrapAssign local \${__assign_isReference}"
alias [integer]='_type=integer Variable::TrapAssign local -i'
alias [array]='_type=array Variable::TrapAssign local -a'
alias [map]='_type=map Variable::TrapAssign local -A'
# TODO: alias [integerArray]='_type=array Variable::TrapAssign local -ai'
alias [boolean]='_type=boolean Variable::TrapAssignLocal'
alias [string[]]='_type=params Variable::TrapAssignLocal'
alias [string[1]]='l=1 _type=params Variable::TrapAssignLocal'
alias [string[2]]='l=2 _type=params Variable::TrapAssignLocal'
alias [string[3]]='l=3 _type=params Variable::TrapAssignLocal'
alias [string[4]]='l=4 _type=params Variable::TrapAssignLocal'
alias [string[5]]='l=5 _type=params Variable::TrapAssignLocal'
alias [string[6]]='l=6 _type=params Variable::TrapAssignLocal'
alias [string[7]]='l=7 _type=params Variable::TrapAssignLocal'
alias [string[8]]='l=8 _type=params Variable::TrapAssignLocal'
alias [string[9]]='l=9 _type=params Variable::TrapAssignLocal'
alias [string[10]]='l=10 _type=params Variable::TrapAssignLocal'
alias [...rest]='_type=rest Variable::TrapAssignLocal'
alias @required='__capture_valueRequired=true '
# TODO: alias @readonly='__capture_valueReadOnly=true '

declare -g ref=$'\UEFF1A'$'\UEFF1A'
