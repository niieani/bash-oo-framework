### STRING

string.toUpper() {
  @resolve:this

  @return:value "${this^^}"
}

string.=() {
  [string] value
  
  @resolve:this

  this="$value"

  @return
}

### /STRING