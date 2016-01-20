namespace oo/variable

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

	if [[ "$typeInfo" == "reference" ]]
	then
		echo n
	elif [[ "$typeInfo" == "map" ]] || Function::Exists class:${typeInfo}
	then
		echo A
	elif [[ "$typeInfo" == "array" ]]
	then
		echo a
	elif [[ "$typeInfo" == "string" || "$typeInfo" == "boolean" ]]
	then
		echo -
	elif [[ "$typeInfo" == "integer" ]]
	then
		echo i
	elif [[ "$typeInfo" == "integerArray" ]]
	then
		echo ai
	else
		echo ${fallback:-A}
	fi
}

Variable::GetPrimitiveTypeFromDeclarationFlag() {
  local typeInfo="$1"

	if [[ "$typeInfo" == "n"* ]]
	then
		echo reference

	elif [[ "$typeInfo" == "ai"* ]]
	then
		echo integerArray

	elif [[ "$typeInfo" == "a"* ]]
	then
		echo array

	elif [[ "$typeInfo" == "Ai"* ]]
	then
		echo integerMap

	elif [[ "$typeInfo" == "A"* ]]
	then
		echo map

	elif [[ "$typeInfo" == "i"* ]]
	then
		echo integer

	else
		echo string
	fi
}

Variable::ExportDeclarationAndTypeToVariables() {
  local variableName="$1"
  local targetVariable="$2"

  local declaration
  local regexArray="declare -([a-zA-Z-]+) $variableName='(.*)'"
  local regex="declare -([a-zA-Z-]+) $variableName=\"(.*)\""
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
    # declaration="${declaration//$doubleSlashes/$singleSlash}"
  elif [[ "$definition" =~ $regex ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}" ## TODO: is this transformation needed?
    declaration="${declaration//$escapedQuotes/$singleQuote}"
    declaration="${declaration//$doubleSlashes/$singleSlash}"
  fi

  local variableType

  DEBUG Log "Variable Is $variableName = $definition ==== ${BASH_REMATCH[1]}"

  local primitiveType=${BASH_REMATCH[1]}

  local objectTypeIndirect="$variableName[__object_type]"
  if [[ "$primitiveType" =~ [A] && ! -z "${!objectTypeIndirect}" ]]
  then
    DEBUG Log "Object Type $variableName[__object_type] = ${!objectTypeIndirect}"
    variableType="${!objectTypeIndirect}"
  else
    variableType="$(Variable::GetPrimitiveTypeFromDeclarationFlag "$primitiveType")"
    DEBUG Log "Primitive Type $primitiveType Resolved ${variableType}"
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

  eval "$targetVariable=\$declaration"
  eval "${targetVariable}_type=\$variableType"
  # eval "${targetVariable}_type=\${BASH_REMATCH[1]}"
}

Variable::PrintDeclaration() {
  local __declaration
  Variable::ExportDeclarationAndTypeToVariables "$1" __declaration
  echo "$__declaration"
}

alias @get='Variable::PrintDeclaration'