### ARRAY

array.push() {
  @resolve:this
  [string] value

  # subject=array.push Log $(@get this)
  this+=("$value")

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

### /ARRAY