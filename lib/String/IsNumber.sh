String::IsNumber() {
  local input="$1"

  local regex='^-?[0-9]+([.][0-9]+)?$'
  if ! [[ "$input" =~ $regex ]]
  then
    return 1
  fi
  return 0
}
