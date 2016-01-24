Array::Contains() {
  local element
  for element in "${@:2}"
  do
    [[ "$element" = "$1" ]] && return 0
  done
  return 1
}
