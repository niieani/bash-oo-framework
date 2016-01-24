import util/namedParameters

## TODO: consider making Parameters::Methods
## since this actually modifies parameters, not arrays

## static methods should be Array::Method, with capital letter

# static version
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
