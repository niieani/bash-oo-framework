### MAP
## TODO: use vars, not $1-9 so $ref: references are resolved

map.set() {
  @resolve:this

  this["$1"]="$2"

  @return #this
}

map.delete() {
  @resolve:this

  unset this["$1"]

  @return #this
}

map.get() {
  @resolve:this

  @return:value "${this[$1]}"
}

### /MAP


## TODO:
#array::Assign() {
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
#map::Assign() {
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