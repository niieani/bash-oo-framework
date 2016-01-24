String::GetSpaces() {
  local howMany="$1"

  if [[ "$howMany" -gt 0 ]]
  then
    ( printf "%*s" "$howMany" )
  fi
}
