namespace oo/type
import util/variable

# depends on modules: variable, exception

declare -g ref=D10F7FB728364261BB50A7E818D537C4
declare -g var=A04FB7D7594E479B8CD8D90C5014E37A

# TODO: required parameters
Variable::TrapAssignNumberedParameter() {
  # USE DEFAULT IFS IN CASE IT WAS CHANGED
  local IFS=$' \t\n'

  local commandWithArgs=( $1 )
  local command="${commandWithArgs[0]}"

  shift
  #  Log "TRAP: ${commandWithArgs[@]}"

  if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* || "$command" == "_isRequired="* || "$command" == "_isReadOnly="*  || "$command" == "_noHandle="* || "$command" == "_isGlobal="* ]]
  then
    return 0
  fi

  if [[ "${commandWithArgs[*]}" == "true" ]]
  then
    __assign_next=true
    DEBUG subject="parameters-assign" Log "Will assign next one"

    local nextAssignment=$(( ${__assign_paramNo:-0} + 1 ))
    if [[ "${!nextAssignment-}" == "$ref:"* ]]
    then
      DEBUG subject="parameters-reference" Log "next param ($nextAssignment) is an object reference"
      __assign_parameters="-n"
    ## TODO: type checking
    else
      __assign_parameters=""
    fi
    return 0
  fi

  local varDeclaration="${commandWithArgs[*]:1}"
  if [[ $varDeclaration == '-'* || $varDeclaration == '${__assign'* ]]
  then
    varDeclaration="${commandWithArgs[*]:2}"
  fi
  local varName="${varDeclaration%%=*}"

  # var value is only important if making an object later on from it
  local varValue="${varDeclaration#*=}"
  # TODO: checking for parameter existence or default value

  if [[ "${__assign_varType:-null}" != "null" ]]
  then
    local requiredType="$__assign_varType" ## TODO: use this information
    [[ $__assign_parameters == '-n' ]] && __assign_varType="reference"

    DEBUG subject="parameters-setting" Log "SETTING: [$__assign_varType] $__assign_varName = \$$__assign_paramNo [rq:$__assign_valueRequired]" # [val:${!__assign_paramNo}]
    # subject="parameters-setting" Log --

    if [[ "$__assign_valueRequired" == 'true' && -z "${!__assign_paramNo+x}" ]]
    then
      e="Value is required for the parameter $__assign_varName ($__assign_paramNo) of type [$__assign_varType]" throw
    fi

    unset __assign_valueRequired __assign_valueReadOnly

    local indirectAccess="$__assign_paramNo"

    if [[ "${!indirectAccess-}" == "$var:"* ]]
    then
      local realVarName="${!indirectAccess#*$var:}"
      if Variable::Exists "$realVarName"
      then
        local __declaration
        local __declaration_type
        Variable::ExportDeclarationAndTypeToVariables "$realVarName" __declaration
        # Log realVarName "${!indirectAccess#*$var:}" type "$declaration_type vs $__assign_varType" declaration: "$__declaration" vs "$(Variable::PrintDeclaration "$realVarName")"
        indirectAccess=__declaration

        if [[ "$__declaration_type" != "$__assign_varType" && "$__assign_varType" != 'params' && "$__assign_varType" != 'rest' ]]
        then
          e="Passed in variable: ($__assign_paramNo) $__assign_varName is of different than its required type [required: $__assign_varType] [actual: $__declaration_type]" throw
        fi
      fi
    fi

    case "$__assign_varType" in
      'params')
      # passing array:
        eval "__assign_arrLength=$__assign_arrLength"
        eval "$__assign_varName=( \"\${@:$__assign_paramNo:$__assign_arrLength}\" )"

        ## TODO: foreach param expand $var: indirectAccess
        __assign_paramNo+=$(($__assign_arrLength - 1))
        unset __assign_arrLength
      ;;
      'rest')
      ## TODO: foreach param expand $var: indirectAccess
        eval "$__assign_varName=( \"\${@:$__assign_paramNo}\" )"
      ;;
      'boolean')
        DEBUG Log passed "${!indirectAccess}", default "${__assign_varValue}"
        local boolean_fingerprint="${__primitive_extension_fingerprint__boolean:+__primitive_extension_fingerprint__boolean:}"

        if [[ ! -z "${!indirectAccess-}" ]]
        then
          if [[ "${!indirectAccess}" == "${boolean_fingerprint}"* ]]
          then
            __assign_varValue="${!indirectAccess}"
          elif [[ "${!indirectAccess}" == 'true' || "${!indirectAccess}" == 'false' ]]
          then
            __assign_varValue="${boolean_fingerprint}${!indirectAccess}"
          else
            __assign_varValue="${boolean_fingerprint}false"
          fi
        elif [[ "${__assign_varValue}" == 'true' || "${__assign_varValue}" == 'false' ]]
        then
          __assign_varValue="${boolean_fingerprint}${__assign_varValue}"
        elif [[ "${__assign_varValue}" != "${boolean_fingerprint}true" && "${__assign_varValue}" != "${boolean_fingerprint}false" ]]
        then
          __assign_varValue="${boolean_fingerprint}false"
        fi
        eval "$__assign_varName=\"${__assign_varValue}\""
      ;;
      'string'|'integer'|'reference')
        if [[ "$__assign_varType" == "reference" || ! -z "${!indirectAccess-}" ]]
        then
          if [[ "${!indirectAccess}" == "$ref:"* ]]
          then
            local refVarName="${!indirectAccess#*$ref:}"
            eval "$__assign_varName=$refVarName"
          else
            DEBUG Log "Will eval $__assign_varName=\"\$$indirectAccess\""
            # escape $indirectAccess with \"
            # local escapedAssignment="${!indirectAccess}"
            # escapedAssignment="${escapedAssignment//\"/\\\"}"
            # execute="$__assign_varName=\"$escapedAssignment\""
            eval "$__assign_varName=\"\$$indirectAccess\""
          fi

        # DEBUG subject="parameters-executing" Log "EXECUTING: $execute"
        fi
      ;;
      *) # 'array'|'map'|objects
        if [[ ! -z "${!indirectAccess}" ]]
        then
          eval "local -$(Variable::GetDeclarationFlagFromType '$__assign_varType') tempMap=\"\$$indirectAccess\""
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
    esac

    unset __assign_varType
    unset __assign_parameters

    if [[ "$__assign_valueGlobal" == "true" ]]; then
      local declaration="$(declare -p $__assign_varName)"
      declaration="${declaration/declare/declare -g}"
      eval "$declaration"
    fi
    unset __assign_valueGlobal

    if [[ "$__assign_noHandle" != 'true' && ! -z ${__oo__bootstrapped+x} ]] && declare -f 'Type::CreateHandlerFunction' &> /dev/null
    then
      DEBUG Log "Will create handle for $__assign_varName"
      Type::CreateHandlerFunction "$__assign_varName" # 2> /dev/null || true
    fi
  fi

  if [[ "$command" != "local" || "${__assign_next-}" != "true" ]]
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
    __assign_valueGlobal="$__capture_valueGlobal"
    __assign_noHandle="$__capture_noHandle"

    DEBUG subject="parameters-pass" Log "PASS ${commandWithArgs[*]}"
    # subject="parameters-pass" Log --

    __assign_paramNo+=1
  fi
}

Variable::InTrapCaptureParameters() {
  DEBUG subject="parameters" Log "Capturing Type $_type"
  # subject="parameters" Log --

  __capture_type="$_type"
  __capture_arrLength="${l-'${#@}'}"
  __capture_valueRequired="${_isRequired-false}"
  __capture_valueReadOnly="${_isReadOnly-false}"
  __capture_valueGlobal="${_isGlobal-false}"
  __capture_noHandle="${_noHandle-false}"
}

## ARGUMENT RESOLVERS ##

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias Variable::TrapAssign='Variable::InTrapCaptureParameters; local -i __assign_normalCodeStarted=0; trap "declare -i __assign_paramNo; Variable::TrapAssignNumberedParameter \"\$BASH_COMMAND\" \"\$@\"; [[ \$__assign_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __assign_varType __assign_varName __assign_varValue __assign_paramNo __assign_valueRequired __assign_valueReadOnly __assign_valueGlobal __assign_noHandle" DEBUG; true; true; '
alias [reference]='_type=reference Variable::TrapAssign local -n'
alias Variable::TrapAssignLocal='Variable::TrapAssign local ${__assign_parameters}'
alias [string]="_type=string Variable::TrapAssignLocal"
# alias [string]="_type=string Variable::TrapAssign local \${__assign_parameters}"
alias [integer]='_type=integer Variable::TrapAssign local ${__assign_parameters:--i}'
alias [array]='_type=array Variable::TrapAssign local ${__assign_parameters:--a}'
alias [map]='_type=map Variable::TrapAssign local ${__assign_parameters:--A}'
# TODO: alias [integerArray]='_type=array Variable::TrapAssign local ${__assign_parameters:--ai}'
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
alias @required='_isRequired=true'
alias @handleless='_noHandle=true'
alias @global='_isGlobal=true'
# TODO: alias @readonly='_isReadOnly=true '
