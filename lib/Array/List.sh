import util/namedParameters

## generates a list separated by new lines
Array::List() {
  @required [string] variableName
  [string] separator=$'\n'

  local indirectAccess="${variableName}[*]"
  (
    local IFS="$separator"
    echo "${!indirectAccess}"
  )
}
