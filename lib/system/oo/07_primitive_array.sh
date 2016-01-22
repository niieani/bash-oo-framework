### ARRAY

## these three are same as map - make map extend array and merge in the future
array.get() {
  @return:value "${this[$1]}"
}

array.set() {
  this["$1"]="$2"

  @return #this
}

array.delete() {
  unset this["$1"]

  @return #this
}

array.push() {
  [...rest] values
  
  local value
  
  for value in "${values[@]}"
  do
    this+=("$value")
  done

  @return
}

array.length() {
	local value="${#this[@]}"
  @return value
}

array.contains() {
  local element

  @return # is it required? TODO: test

  ## TODO: probably should return a [boolean] type, not normal return

  for element in "${this[@]}"
  do
    [[ "$element" == "$1" ]] && return 0
  done
  return 1
}

array.indexOf() {
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
  @required [array] concatWithArray
  
  concatWithArray forEach 'this push "$(item)"'
  
  @return this
}

array.concat() {
  @required [array] concatWithArray
  
  array outArray=$(this)
  
  concatWithArray forEach 'outArray push "$(item)"'
  
  @return outArray
}

array.getLastElement() {
  @return:value "${this[(${#this[@]}-1)]}"
  # alternative in bash 4.2: ${this[-1]}
}

array.withoutLastElement() {
  @return:value "${this[@]:0:(${#this[@]}-1)}"
}

array.toString() {
  [string] separator=$'\n'
  @return:value "$(Array::List this "$separator")"
}

array.toJSON() {
  @return:value "$(Array::ToJSON this)"
}


array.every() {
	[integer] every
	[integer] startingIndex
  
  array returnArray
  
	local -i count=0

	local index
	for index in "${!this[@]}"
	do
		if [[ $index -eq $(( $every * $count + $startingIndex )) ]]
		then
			#echo "$index: ${this[$index]}"
			returnArray+=( "${this[$index]}" )
			count+=1
		fi
	done
  
  @return returnArray
}

Type::Initialize array primitive
### STATIC METHODS

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

Array::ToJSON() {
  @required [string] variableName
  
  ## TODO: escape quotes by doing 
  # foreach and using declare -p for values and unescaping '
  # echo -n "["
  (
    local IFS=$'\UFFFFF'
    local indirectAccess="${variableName}[*]"
    local list="\"${!indirectAccess}\""
    local separator='", "'
    echo -n "[${list/$'\UFFFFF'/$separator}]"
  )
  # echo -n "]"
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

Array::Reverse() {
  [...rest] this

  local -i length=${#this[@]}  #$(this length)
  local -a outArray
  local -i indexFromEnd
  local -i index

  for index in "${!this[@]}"
  do
    indexFromEnd=$(( $length - 1 - $index ))
    outArray+=( "${this[$indexFromEnd]}" )
  done

  @get outArray
}
### /ARRAY