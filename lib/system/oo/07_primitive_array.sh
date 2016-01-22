### ARRAY

array.push() {
  [...rest] values
  
  @resolve:this
  
  local value
  
  for value in "${values[@]}"
  do
    this+=("$value")
  done

  @return
}

array.length() {
  @resolve:this

	local value="${#this[@]}"
  @return value
}

array.contains() {
  @resolve:this

  local element

  @return # is it required?

  ## TODO: probably should return a [boolean] type, not normal return

  for element in "${this[@]}"
  do
    [[ "$element" == "$1" ]] && return 0
  done
  return 1
}

array.indexOf() {
  @resolve:this

  # Log this: $(declare -p this)

  local index

  for index in "${!this[@]}"
  do
    # Log index: $index "${!this[@]}"
    # Log value: "${this[$index]}"
    [[ "${this[$index]}" == "$1" ]] && @return:value $index && return
  done
  @return:value -1
}

array.reverse() {
  @resolve:this

  # Log reversing: $(@get this)
  local -i length=${#this[@]}  #$(this length)
  local -a outArray
  local -i indexFromEnd
  local -i index

  for index in "${!this[@]}"
  do
    indexFromEnd=$(( $length - 1 - $index ))
    outArray+=( "${this[$indexFromEnd]}" )
  done

  @return outArray
}

array.forEach() {
  [string] action
  @resolve:this

  string item
  integer index

  eval "__array_forEach_temp_method() { $action ; }"

  for index in "${!this[@]}"
  do
    item="${this[$index]}"
    __array_forEach_temp_method "$item" "$index"
  done

  unset __array_forEach_temp_method

  @return
}

array.map() {
  [string] action
  
  @resolve:this

  string item
  integer index
  array out

  eval "__array_map_temp_method() { $action ; }"

  for index in "${!this[@]}"
  do
    item="${this[$index]}"
    out[$index]=$(__array_map_temp_method "$item" "$index")
  done

  unset __array_map_temp_method

  @return out
}


array.concatPush() {
  @resolve:this
  
  @required [array] concatWithArray
  
  concatWithArray forEach 'this push "$(item)"'
  
  @return this
}

array.concat() {
  @resolve:this
  
  @required [array] concatWithArray
  
  array outArray=$(this)
  
  concatWithArray forEach 'outArray push "$(item)"'
  
  @return outArray
}

array.getLastElement() {
  @resolve:this
  
  @return:value "${this[(${#this[@]}-1)]}"
  # alternative in bash 4.2: ${this[-1]}
}

array.withoutLastElement() {
  @resolve:this
  @return:value "${this[@]:0:(${#this[@]}-1)}"
}

array.toString() {
  @resolve:this
  
  @return:value "$(Array::List this)"
}

array.toJSON() {
  @resolve:this
  
  @return:value "$(Array::ToJSON this)"
}

### STATIC METHODS

## generates a list separated by new lines
Array::List() {
  @required [string] variableName
  
  local indirectAccess="$variableName[*]"
  IFS=$'\n' echo "${!indirectAccess}"
}

Array::ToJSON() {
  @required [string] variableName
  
  ## TODO: escape quotes
  echo -n "["
  (
    local IFS=$'\UFFFFF'
    local indirectAccess="${variableName}[*]"
    local list="\"${!indirectAccess}\""
    local separator='", "'
    echo -n "${list/$'\UFFFFF'/$separator}"
  )
  echo -n "]"
}

Array::Intersect() {
  @required [array] arrayA
  @required [array] arrayB

  array intersection

  # http://stackoverflow.com/questions/2312762/compare-difference-of-two-arrays-in-bash
  for i in "${arrayA[@]}"
  do
    local skip=
    for j in "${arrayB[@]}"
    do
      [[ "$i" == "$j" ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || intersection+=("$i")
  done

  @get intersection
}
### /ARRAY