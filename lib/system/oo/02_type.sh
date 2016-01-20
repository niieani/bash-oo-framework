namespace oo/type

__primitive_extension_declaration=2D6A822E
__primitive_extension_fingerprint__boolean=${__primitive_extension_declaration}36884C70843578D37E6773C4

# /**
#   * Code like: Variable::ExportDeclarationAndTypeToVariables
#   */
Type::GetTypeOfVariable() {
  local variableName="$1"

  local regex="declare -([a-zA-Z-]+) $variableName=(.*)"
  local definition=$(declare -p "${variableName}" 2> /dev/null || true)

  [[ -z "$definition" ]] && e="Variable not defined" throw
  if [[ "$definition" =~ $regex ]]
  then
      local variableType
      local primitiveType=${BASH_REMATCH[1]}

      local objectTypeIndirect="$variableName[__object_type]"
      if [[ "$primitiveType" =~ [A] && ! -z "${!objectTypeIndirect}" ]]
      then
        DEBUG Log "typeof $variableName: Object Type $variableName[__object_type] = ${!objectTypeIndirect}"
        variableType="${!objectTypeIndirect}"
      else
        variableType="$(Variable::GetPrimitiveTypeFromDeclarationFlag "$primitiveType")"
        DEBUG Log "typeof $variableName: Primitive Type $primitiveType Resolved ${variableType}"
      fi

      if [[ "$variableType" == 'string' ]]
      then
        local extensionType=$(Type::GetPrimitiveExtensionFromVariable "${variableName}")
        if [[ ! -z "$extensionType" ]]
        then
          variableType="$extensionType"
        fi
      fi

      DEBUG Log "Variable $variableName is typeof $variableType"

      echo "$variableType"
  fi

#	local typeInfo="$(declare -p $1 2> /dev/null || declare -p | grep "^declare -[aAign\-]* $1\(=\|$\)" || true)"
#
#	if [[ -z "$typeInfo" ]]
#	then
#		echo undefined
#		return
#	fi
#
#	if [[ "$typeInfo" == "declare -n"* ]]
#	then
#		echo reference
#	elif [[ "$typeInfo" == "declare -a"* ]]
#	then
#		echo array
#	elif [[ "$typeInfo" == "declare -ai"* ]]
#	then
#		echo integerArray
#	elif [[ "$typeInfo" == "declare -A"* ]]
#	then
#    local __object_type_ref="$1[__object_type]"
#    local __object_type="${!__object_type_ref}"
#    if [[ ! -z "${__object_type}" ]]
#    then
#      echo $__object_type
#    else
#		  echo map
#    fi
#	elif [[ "$typeInfo" == "declare -i"* ]]
#	then
#		echo integer
#	else
#		echo string
#	fi
}

Type::IsPrimitive() {
  local type="$1"

  case "$type" in
    'array'|'map'|'string'|'integer'|'boolean'|'integerArray')
      return 0 ;;
    * )
      return 1 ;;
  esac
}

## Returns a matching __primitive_extension_fingerprint__*
## Or nothing
Type::GetPrimitiveExtensionFromVariable() {
  local variableName="$1"

  if [[ "${!variableName}" != "$__primitive_extension_declaration"* ]]
  then
    return
  fi

  local prefix=__primitive_extension_fingerprint__
  local extensionType
  for extensionType in $(Variable::GetAllStartingWith $prefix)
  do
    local fingerprint=${!extensionType}
    if [[ "${!variableName}" == "$fingerprint"* ]]
    then
      extensionType=${extensionType##$prefix}
      echo "$extensionType"
      return
    fi
  done
}

Type::GetPrimitiveExtensionFingerprint() {
  local type="$1"

  local fingerprintVariable="__primitive_extension_fingerprint__${type}"
  printf "${!fingerprintVariable}"
}

Type::CreateHandlerFunction() {
  local variableName="$1"

  ## declare method with the name of the var ##
  eval "$variableName() {
    Type::Handle $variableName \"\$@\";
  }"
}

Type::TrapAndCreate() {
  # set -x
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'

    local commandWithArgs=( $1 )
    local command="${commandWithArgs[0]}"

    shift

    # Log "${commandWithArgs[*]}"

    if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* ]]
    then
        # set +x
        return 0
    fi

    if [[ "${commandWithArgs[*]}" == "true" ]]
    then
        __typeCreate_next=true
        # Console::WriteStrErr "Will assign next one"
        # set +x
        return 0
    fi

    local varDeclaration="${commandWithArgs[*]:1}"
    if [[ $varDeclaration == '-'* ]]
    then
        varDeclaration="${commandWithArgs[*]:2}"
    fi
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"

    # TODO: make this better:
    if [[ "$varValue" == "$varName" ]]
    then
      # Log "equal $varName=$varValue"
    	local varValue=""
    fi

    if [[ ! -z $__typeCreate_varType ]]
    then

      local __primitive_extension_fingerprint__boolean=${__primitive_extension_fingerprint__boolean:-2D6A822E36884C70843578D37E6773C4}
      # Console::WriteStrErr "SETTING $__typeCreate_varName = \$$__typeCreate_paramNo"
      # Console::WriteStrErr --
      #Console::WriteStrErr $tempName

    	DEBUG Log "creating: $__typeCreate_varName ($__typeCreate_varType) = $__typeCreate_varValue"

    	if [[ -z "$__typeCreate_varValue" ]]
      then
        case "$__typeCreate_varType" in
          'array'|'map') eval "$__typeCreate_varName=()" ;;
          'string') eval "$__typeCreate_varName=''" ;;
          'integer') eval "$__typeCreate_varName=0" ;;
          'boolean') eval "$__typeCreate_varName=${__primitive_extension_fingerprint__boolean}:false" ;;
          * )
            # Log "constructing: $__typeCreate_varName ($__typeCreate_varType) = $(__constructor_recursion=0 Type::Construct $__typeCreate_varType)"

            # eval "$__typeCreate_varName=\$(__constructor_recursion=0 Type::Construct \$__typeCreate_varType)"
            __constructor_recursion=0 Type::Construct "$__typeCreate_varType" "$__typeCreate_varName"

            DEBUG Log "constructed: $(@get $__typeCreate_varName)"

            # Type::Construct w
            ## TODO: initialize all the sub-objects recursively
            # eval "$__typeCreate_varName=([__object_type]=$__typeCreate_varType)" ;;
          ;;
        esac
      else
        case "$__typeCreate_varType" in
          'boolean')
            if [[ "${__typeCreate_varValue}" != 'true' && "${__typeCreate_varValue}" != 'false' ]]
            then
              __typeCreate_varValue='false'
            fi
            eval "$__typeCreate_varName=\"${__primitive_extension_fingerprint__boolean}:${__typeCreate_varValue}\"" ;;
          *) ;;
        esac
      fi

      Type::CreateHandlerFunction "$__typeCreate_varName"

      ## IMPORTANT: TRAP won't work inside a TRAP

      # case "$__typeCreate_varType" in
      #   'array'|'map'|'string'|'integer') ;;
      #   *)
      #     if Function::Exists ${__typeCreate_varType}.constructor
      #     then
      #       # __typeCreate_runConstructor=${__typeCreate_varName}
      #       # Log __typeCreate_runConstructor $__typeCreate_runConstructor
      #       ${__typeCreate_varName} constructor
      #     fi
      #     # local return
      #     # Object.New $__typeCreate_varType $__typeCreate_varName
      #     # eval "$__typeCreate_varName=$return"
      #   ;;
      # esac

    	# __oo__objects+=( $__typeCreate_varName )

      unset __typeCreate_varType
      unset __typeCreate_varValue
    fi

    if [[ "$command" != "declare" || "$__typeCreate_next" != "true" ]]
    then
        __typeCreate_normalCodeStarted+=1

        # Console::WriteStrErr "NOPASS ${commandWithArgs[*]}"
        # Console::WriteStrErr "normal code count ($__typeCreate_normalCodeStarted)"
        # Console::WriteStrErr --
    else
        unset __typeCreate_next

        __typeCreate_normalCodeStarted=0
        __typeCreate_varName="$varName"
        __typeCreate_varValue="$varValue"
        __typeCreate_varType="$__capture_type"
        __typeCreate_arrLength="$__capture_arrLength"

        # Console::WriteStrErr "PASS ${commandWithArgs[*]}"
        # Console::WriteStrErr --

        __typeCreate_paramNo+=1
    fi
    # set +x
}

Type::CaptureParams() {
    # Console::WriteStrErr "Capturing Type $_type"
    # Console::WriteStrErr --

    __capture_type="$_type"
}

# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias Type::TrapAssign='Type::CaptureParams; declare -i __typeCreate_normalCodeStarted=0; trap "declare -i __typeCreate_paramNo; Type::TrapAndCreate \"\$BASH_COMMAND\" \"\$@\"; [[ \$__typeCreate_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __typeCreate_varType && unset __typeCreate_varName && unset __typeCreate_varValue && unset __typeCreate_paramNo" DEBUG; true; true; '
alias reference='_type=reference Type::TrapAssign declare -n'
alias string='_type=string Type::TrapAssign declare'
alias boolean='_type=boolean Type::TrapAssign declare'
alias integer='_type=integer Type::TrapAssign declare -i'
alias array='_type=array Type::TrapAssign declare -a'
alias array[integer]='_type=integerArray Type::TrapAssign declare -ai'
alias map='_type=map Type::TrapAssign declare -A'
#alias global:reference='_type=reference Type::TrapAssign declare -ng'
#alias global:string='_type=string Type::TrapAssign declare -g'
#alias global:integer='_type=integer Type::TrapAssign declare -ig'
#alias global:array='_type=array Type::TrapAssign declare -ag'
#alias global:map='_type=map Type::TrapAssign declare -Ag'


##############################

# for use in the object's methods
this() {
  Type::Handle this "$@"
}

__return_separator=52A586A48E074BB6812DCFDC790841F5

@return() {
  local variableName="$1"

  local __return_declaration
  local __return_declaration_type

  ## if not returning anything, just update the self
  if [[ ! -z "$variableName" ]]
  then
    Variable::ExportDeclarationAndTypeToVariables $variableName __return_declaration
  elif [[ ! -z "${monad+x}" ]]
  then
    Variable::ExportDeclarationAndTypeToVariables this __return_declaration
  fi

  if [[ "${__local_return_self_and_result}" == "true" || "${__return_self_and_result}" == "true" ]]
  then
    # Log "returning heavy"
    local -a __return=("$(Variable::PrintDeclaration this)" "$__return_declaration" "$__return_declaration_type")

    printf ${__return_separator:-52A586A48E074BB6812DCFDC790841F5}
    Variable::PrintDeclaration __return
    # __modifiedThis="$(Variable::PrintDeclaration this)"
  elif [[ "${#__return_declaration}" -gt 0 ]]
  then
    echo "$__return_declaration"
  fi
}

@return:value() {
  local value="$@"
  @return value
}

# ------------------------ #

