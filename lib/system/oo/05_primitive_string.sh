### STRING

string.toUpper() {
  @return:value "${this^^}"
}

string.=() {
  [string] value

  this="$value"

  @return
}

Type::Initialize string primitive

### /STRING