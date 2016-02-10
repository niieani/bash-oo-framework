import util/namedParameters util/type Array

namespace oo/type
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

  string methodName=__array_forEach_temp_method
  eval "$methodName() { $action ; }"

  # DEBUG Console::WriteStdErr "escaping: $methodName() { $action ; }"

  for index in "${!this[@]}"
  do
    item="${this[$index]}"
    # eval "$action"
    $methodName "$item" "$index"
  done

  unset -f $methodName

  @return
}

array.map() {
  [string] action

  string item
  integer index
  array out

  string methodName=__array_map_temp_method

  eval "$methodName() { $action ; }"

  for index in "${!this[@]}"
  do
    item="${this[$index]}"
    out[$index]=$($methodName "$item" "$index")
  done

  unset -f $methodName

  @return out
}


array.concatPush() {
  @required [array] concatWithArray

  # TODO: why doesn't this work? seems that it is run in a subshell?
  # var: concatWithArray forEach 'var: self push "$(var: item)"'

  local index
  for index in "${!concatWithArray[@]}"
  do
    this push "${concatWithArray[$index]}"
  done

  @return
}

array.concat() {
  @required [array] concatWithArray

  array outArray=$(this)

  local index
  for index in "${!concatWithArray[@]}"
  do
    var: outArray push "${concatWithArray[$index]}"
  done

  # TODO:
  # var: concatWithArray forEach 'var: outArray push "$(var: item)"'

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
  string json=$(this forEach 'printf %s "$(var: item toJSON), "')
  @return:value "[${json%,*}]"
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

Type::InitializePrimitive array

### /ARRAY
