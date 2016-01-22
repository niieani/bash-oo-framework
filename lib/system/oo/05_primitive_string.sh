### STRING

string.toUpper() {
  @return:value "${this^^}"
}

string.=() {
  [string] value

  this="$value"

  @return
}

string.toArray() {
  [string] separationCharacter=$'\n' # $'\UFAFAF'
  
  array returnArray
  
	local newLine=$'\n'
	local string="${this//"$newLine"/"$separationCharacter"}"
	local IFS=$separationCharacter
	local element
	for element in $string
	do
		returnArray+=( "$element" )
	done

	local newLines=${string//[^$separationCharacter]}
	local -i trailingNewLines=$(( ${#newLines} - ${#returnArray[@]} + 1 ))
	while (( trailingNewLines-- ))
	do
		returnArray+=( "" )
	done
  
  @return returnArray
}

## test this:
string.matchGroups() {
	@required [string] regex
	[string] returnMatchNumber='@' # @ means all
  
  array returnArray

	DEBUG subject="matchGroups" Log "string to match on: $this"
  
	local -i matchNo=0
	local string="$this"
	while [[ "$string" =~ $regex ]]
	do
		DEBUG subject="regex" Log "match $matchNo: ${BASH_REMATCH[*]}"

		if [[ "$returnMatchNumber" == "@" || $matchNo -eq "$returnMatchNumber" ]]
		then
			returnArray+=( "${BASH_REMATCH[@]}" )
			[[ "$returnMatchNumber" == "@" ]] || @return returnArray && return 0
		fi
		# cut out the match so we may continue
		string="${string/"${BASH_REMATCH[0]}"}" # "
		matchNo+=1
	done
}

string.match() {
	[string] regex
	[integer] capturingGroup
	[string] returnMatchNumber

	DEBUG subject="string.match" Log "string to match on: $this"

	array allMatches=$(this matchGroups "$regex" "$returnMatchNumber")

	@return:value "${allMatches[$capturingGroup]}"
}


Type::Initialize string primitive

### /STRING

## TODO:

#static String.TabsForSpaces() {
#    [string] input
#    # TODO: [string] spaceCount=4
#
#    # hardcoded 1 tab = 4 spaces
#    echo "${input//[	]/    }"
#}
#
#static String.RegexMatch() {
#    [string] text; [string] regex; [string] param
#
#    if [[ "$text" =~ $regex ]]; then
#        if [[ ! -z $param ]]; then
#            echo "${BASH_REMATCH[${param}]}"
#        fi
#        return 0
#    else
#        return 1
#        # no match
#    fi
#}
#
#static String.SpaceCount() {
#    [string] text
#
#    # note: you shouldn't mix tabs and spaces, we explicitly don't count tabs here
#    local spaces="$(String.RegexMatch "$text" "^[	]*([ ]*)[.]*" 1)"
#    echo "${#spaces}"
#}
#
#static String.Trim() {
#    [string] text
#
#    echo "$(String.RegexMatch "$text" "^[ 	]*(.*)" 1)"
#    #text="${text#"${text%%[![:space:]]*}"}"   # remove leading whitespace characters
#    #text="${text%"${text##*[![:space:]]}"}"   # remove trailing whitespace characters
#    #echo -n "$text"
#}
#
#static String.Contains() {
#    [string] string
#    [string] match
#
#    [[ "$string" == *"$match"* ]]
#    return $?
#}
#
#static String.StartsWith() {
#    [string] string
#    [string] match
#
#    [[ "$string" == "$match"* ]]
#    return $?
#}
#
#static String.EndsWith() {
#    [string] string
#    [string] match
#
#    [[ "$string" == *"$match" ]]
#    return $?
#}
#
#method String::GetSanitizedVariableName() {
#    String.GetSanitizedVariableName "$($this)"
#}
#
#method String::RegexMatch() {
#    [string] regex
#    [string] param
#
#    String.RegexMatch "$($this)" "$regex" "$param"
#}