import util/namedParameters util/type

namespace oo/type

### MAP
## TODO: use vars, not $1-9 so $ref: references are resolved

map.set() {
  this["$1"]="$2"

  @return #this
}

map.delete() {
  unset this["$1"]

  @return #this
}

map.get() {
  @return:value "${this[$1]}"
}

Type::InitializePrimitive map

### /MAP


## TODO:
#Array::Assign() {
#  local source="$1"
#  local target="$2"
#
#  eval "local -a tempMap=\"\$$__assign_paramNo\""
#  local index
#  local value
#
#  ## copy the array / map item by item
#  for index in "${!tempMap[@]}"
#  do
#    eval "$__assign_varName[\$index]=\"\${tempMap[\$index]}\""
#  done
#
#  unset index value tempMap
#}
#
#Map::Assign() {
#  ## TODO: test this
#  eval "local -$(Variable::GetDeclarationFlagFromType '$__assign_varType') tempMap=\"\$$__assign_paramNo\""
#  local index
#  local value
#
#  ## copy the array / map item by item
#  for index in "${!tempMap[@]}"
#  do
#    eval "$__assign_varName[\$index]=\"\${tempMap[\$index]}\""
#  done
#
#  unset index value tempMap
#}
