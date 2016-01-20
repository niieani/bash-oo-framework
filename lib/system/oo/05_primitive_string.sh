### STRING


string.toUpper() {
  @resolve:this

  @return:value "${this^^}"
}

string.=() {
  @resolve:this
  [string] value

  this="$value"

  @return
}

### /STRING