import util/command
namespace util/variable

declare __declaration_type ## for Variable::ExportDeclarationAndTypeToVariables (?)

Variable::Exists() {
  local variableName="$1"
  declare -p "$variableName" &> /dev/null
}

Variable::GetAllStartingWith() {
  local startsWith="$1"
  compgen -A 'variable' "$startsWith" || true
}

Variable::GetDeclarationFlagFromType() {
  DEBUG subject="GetParamFromType" Log 'getting param from type' "$@"

  local typeInfo="$1"
  local fallback="$2"

  if [[ "$typeInfo" == "map" ]] || Function::Exists "class:${typeInfo}"
  then
    echo A
  else
    case "$typeInfo" in
      "reference")
        echo n
      ;;
      "array")
        echo a
      ;;
      "string" | "boolean")
        echo -
      ;;
      "integer")
        echo i
      ;;
      "integerArray")
        echo ai
      ;;
      *)
        echo "${fallback:-A}"
      ;;
    esac
  fi
}

Variable::GetPrimitiveTypeFromDeclarationFlag() {
  local typeInfo="$1"

  case "$typeInfo" in
    "n"*)
      echo reference
    ;;
    "a"*)
      echo array
    ;;
    "A"*)
      echo map
    ;;
    "i"*)
      echo integer
    ;;
    "ai"*)
      echo integerArray
    ;;
    "Ai"*)
      echo integerMap
    ;;
    *)
      echo string
    ;;
  esac
}

Variable::ExportDeclarationAndTypeToVariables() {
  local variableName="$1"
  local targetVariable="$2"
  local dereferrence="${3:-true}"

  # TODO: rename for a safer, less common variablename so parents can output to declaration
  local declaration
  local regexArray="declare -([a-zA-Z-]+) $variableName='(.*)'"
  local regex="declare -([a-zA-Z-]+) $variableName=\"(.*)\""
  local regexArrayBash4_4="declare -([a-zA-Z-]+) $variableName=(.*)"
  local definition=$(declare -p $variableName 2> /dev/null || true)

  local escaped="'\\\'"
  local escapedQuotes='\\"'
  local singleQuote='"'

  local doubleSlashes='\\\\'
  local singleSlash='\'

  [[ -z "$definition" ]] && e="Variable $variableName not defined" throw

  if [[ "$definition" =~ $regexArray ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}"
  elif [[ "$definition" =~ $regex ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}" ## TODO: is this transformation needed?
    declaration="${declaration//$escapedQuotes/$singleQuote}"
    declaration="${declaration//$doubleSlashes/$singleSlash}"
  elif [[ "$definition" =~ $regexArrayBash4_4 ]]
  then
    declaration="${BASH_REMATCH[2]}"
  fi

  local variableType

  DEBUG Log "Variable Is $variableName = $definition ==== ${BASH_REMATCH[1]}"

  local primitiveType=${BASH_REMATCH[1]}

  local objectTypeIndirect="$variableName[__object_type]"
  if [[ "$primitiveType" =~ [A] && ! -z "${!objectTypeIndirect}" ]]
  then
    DEBUG Log "Object Type $variableName[__object_type] = ${!objectTypeIndirect}"
    variableType="${!objectTypeIndirect}"
  # elif [[ ! -z ${__primitive_extension_fingerprint__boolean+x} && "$primitiveType" == '-' && "${!variableName}" == "${__primitive_extension_fingerprint__boolean}"* ]]
  # then
  #   variableType="boolean"
  else
    variableType="$(Variable::GetPrimitiveTypeFromDeclarationFlag "$primitiveType")"
    DEBUG Log "Primitive Type $primitiveType Resolved ${variableType}"
  fi

  if [[ "$variableType" == 'string' ]] && Function::Exists 'Type::GetPrimitiveExtensionFromVariable'
  then
    local extensionType=$(Type::GetPrimitiveExtensionFromVariable "${variableName}")
    if [[ ! -z "$extensionType" ]]
    then
      variableType="$extensionType"
    fi
  fi

  DEBUG Log "Variable $variableName is typeof $variableType"

  if [[ "$variableType" == 'reference' && "$dereferrence" == 'true' ]]
  then
    local dereferrencedVariableName="$declaration"
    Variable::ExportDeclarationAndTypeToVariables "$dereferrencedVariableName" "$targetVariable" "$dereferrence"
  else
    eval "$targetVariable=\"\$declaration\""
    eval "${targetVariable}_type=\$variableType"
  fi
}

Variable::PrintDeclaration() {
  local variableName="${1}"
  local dereferrence="${2:-true}"

  local __declaration
  local __declaration_type
  Variable::ExportDeclarationAndTypeToVariables "$variableName" __declaration "$dereferrence"
  echo "$__declaration"
}

alias @get='Variable::PrintDeclaration'
