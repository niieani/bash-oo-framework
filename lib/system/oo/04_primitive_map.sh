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