import util/namedParameters util/type String

namespace oo/type
### STRING

string.=() {
  [string] value

  this="$value"

  @return
}

string.toUpper() {
  @return:value "${this^^}"
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
string.getMatchGroups() {
	@handleless @required [string] regex
	[string] returnMatchNumber='@' # @ means all

  array returnArray

	subject="matchGroups" Log "string to match on: $this"

	local -i matchNo=0
	local string="$this"
	while [[ "$string" =~ $regex ]]
	do
		subject="regex" Log "match $matchNo: ${BASH_REMATCH[*]}"

		if [[ "$returnMatchNumber" == "@" || $matchNo -eq "$returnMatchNumber" ]]
		then
			returnArray+=( "${BASH_REMATCH[@]}" )
			[[ "$returnMatchNumber" == "@" ]] || { @return returnArray && return 0; }
		fi
		# cut out the match so we may continue
		string="${string/"${BASH_REMATCH[0]}"}" # "
		matchNo+=1
	done

  @return returnArray
}

string.match() {
	@handleless @required [string] regex
	[integer] capturingGroup=0
	[string] returnMatchNumber=0 # @ means all

	DEBUG subject="string.match" Log "string to match on: $this"

	array allMatches=$(this getMatchGroups "$regex" "$returnMatchNumber")

	@return:value "${allMatches[$capturingGroup]}"
}

string.toJSON() {
  ## http://stackoverflow.com/a/3020108/595157

  string escaped="$this"
  escaped=$(var: escaped forEachChar '(( 16#$(var: char getCharCode) < 20 )) && printf "\\${char}" || printf "$char"')

  escaped="${escaped//\\/\\\\}" ## slashes
  escaped="\"${escaped//\"/\\\"}\"" ## quotes

  @return escaped
}

string.forEachChar() {
  [string] action

  string char
  integer index

  string methodName=__string_forEachChar_temp_method

  eval "$methodName() { $action ; }"

  for (( index=0; index<${#this}; index++ ))
  do
    char="${this:$index:1}"
    $methodName "$char" "$index"
  done

  unset -f $methodName

  @return
}

string.getCharCode() {
  ## returns char code of the first character
  @return:value $(printf %x "'$this")
}

Type::InitializePrimitive string

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
