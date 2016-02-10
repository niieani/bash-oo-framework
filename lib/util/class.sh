namespace util/type
import util/type String/SanitizeForVariable
# ------------------------ #

Type::DefineProperty() {
  local visibility="$1"
  local class="$2"
  local type="$3"
  local property="$4"
  local assignment="$5"
  local defaultValue="$6"

  class="${class//[^a-zA-Z0-9]/_}"

  eval "__${class}_property_names+=( '$property' )"
  eval "__${class}_property_types+=( '$type' )"
  eval "__${class}_property_visibilities+=( '$visibility' )"
  # if [[ "$assignment" == '=' && ! -z "$defaultValue" ]]
  # then
    eval "__${class}_property_defaults+=( \"\$defaultValue\" )"
  # fi
}

private() {
  # ${FUNCNAME[1]} contains the name of the class
  local class=${FUNCNAME[1]#*:}

  Type::DefineProperty private $class "$@"
}

public() {
  # ${FUNCNAME[1]} contains the name of the class
  local class=${FUNCNAME[1]#*:}

  Type::DefineProperty public $class "$@"
}

Type::Initialize() {
  local name="$1"
  local style="${2:-default}"

  Function::Exists class:$name && class:$name || true

  Type::ConvertAllOfTypeToMethodsIfNeeded "$name"

  case "$style" in
    'primitive') ;;
    'static')
      declare -Ag __oo_static_instance_${name}="$(Type::Construct $name)"
      eval "${name}"'(){ '"Type::Handle __oo_static_instance_${name}"' "$@"; }'
    ;;
    *)
      ## add alias for parameters
      alias [$name]="_type=$name Variable::TrapAssign local -A"

      ## add alias for creating vars
      alias $name="_type=$name Type::TrapAssign declare -A"
    ;;
  esac
}

Type::InitializeStatic() {
  local name="$1"

  Type::Initialize "$name" static
}

Type::Construct() {
  local type="$1"
  local typeSanitized=$(String::SanitizeForVariableName $type)
  local assignToVariable="$2"

  if [[ ! -z "${__constructor_recursion+x}" ]]
  then
    __constructor_recursion=$(( ${__constructor_recursion} + 1 ))
  fi

  local -A constructedType=( [__object_type]="$type" )
  # else
  #   echo "$assignToVariable[__object_type]=\"$type\""
  # fi

  if Variable::Exists "__${typeSanitized}_property_names"
  then
    local propertyIndexesIndirect="__${typeSanitized}_property_names[@]"
    local -i propertyIndex=0
    local propertyName
    for propertyName in "${!propertyIndexesIndirect}"
    do
      # local propertyNameIndirect=__${typeSanitized}_property_names[$propertyIndex]
      # local propertyName="${!propertyNameIndirect}"

      local propertyTypeIndirect=__${typeSanitized}_property_types[$propertyIndex]
      local propertyType="${!propertyTypeIndirect}"

      local defaultValueIndirect=__${typeSanitized}_property_defaults[$propertyIndex]
      local defaultValue="${!defaultValueIndirect}"

      if [[ $propertyType == 'boolean' ]] && [[ "$defaultValue" == 'false' || "$defaultValue" == 'true' ]]
      then
        defaultValue="${__primitive_extension_fingerprint__boolean}:$defaultValue"
      fi

      local constructedPropertyDefinition="$defaultValue"

      DEBUG Log "iterating type: ${typeSanitized}, property: [$propertyIndex] $propertyName = $defaultValue"

      ## AUTOMATICALLY CONSTRUCTS THE PROPERTIES:
      # case "$propertyType" in
      #   'array'|'map'|'string'|'integer'|'integerArray') ;;
      #       # 'integer') constructedPropertyDefinition="${__integer_fingerprint}$defaultValue" ;;
      #       # 'integerArray') constructedPropertyDefinition="${__integer_array_fingerprint}$defaultValue" ;;
      #   * )
      #     if [[ -z "$defaultValue" && "$__constructor_recursion" -lt 15 ]]
      #     then
      #       constructedPropertyDefinition=$(Type::Construct "$propertyType")
      #     fi
      #   ;;
      # esac

      if [[ ! -z "$constructedPropertyDefinition" ]]
      then
        ## initialize non-empty fields

        DEBUG Log "Will exec: constructedType+=( [\"$propertyName\"]=\"$constructedPropertyDefinition\" )"
        constructedType+=( ["$propertyName"]="$constructedPropertyDefinition" )
        # eval 'constructedType+=( ["$propertyName"]="$constructedPropertyDefinition" )'
      fi

      propertyIndex+=1
    done
  fi

  if [[ -z "$assignToVariable" ]]
  then
    Variable::PrintDeclaration constructedType
  else
    local constructedIndex
    for constructedIndex in "${!constructedType[@]}"
    do
      eval "$assignToVariable[\"\$constructedIndex\"]=\"\${constructedType[\"\$constructedIndex\"]}\""
    done
  fi
}

alias new='Type::Construct'
