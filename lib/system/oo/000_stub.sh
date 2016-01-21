string::SanitizeForVariableName() {
  local type="$1"
  echo "${type//[^a-zA-Z0-9]/_}"
}

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