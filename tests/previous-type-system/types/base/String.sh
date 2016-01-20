import Var

class:String() {
    extends Var

    static String.GetSanitizedVariableName() {
        [string] input

        local clean="${input//[^a-zA-Z0-9]/_}"
        echo "${clean^^}"
    }

    static String.TabsForSpaces() {
        [string] input
        # TODO: [string] spaceCount=4

        # hardcoded 1 tab = 4 spaces
        echo "${input//[	]/    }"
    }

    static String.RegexMatch() {
        [string] text; [string] regex; [string] param

        if [[ "$text" =~ $regex ]]; then
            if [[ ! -z $param ]]; then
                echo "${BASH_REMATCH[${param}]}"
            fi
            return 0
        else
            return 1
            # no match
        fi
    }

    static String.SpaceCount() {
        [string] text

        # note: you shouldn't mix tabs and spaces, we explicitly don't count tabs here
        local spaces="$(String.RegexMatch "$text" "^[	]*([ ]*)[.]*" 1)"
        echo "${#spaces}"
    }

    static String.Trim() {
        [string] text

        echo "$(String.RegexMatch "$text" "^[ 	]*(.*)" 1)"
        #text="${text#"${text%%[![:space:]]*}"}"   # remove leading whitespace characters
        #text="${text%"${text##*[![:space:]]}"}"   # remove trailing whitespace characters
        #echo -n "$text"
    }

    static String.Contains() {
        [string] string
        [string] match

        [[ "$string" == *"$match"* ]]
        return $?
    }

    static String.StartsWith() {
        [string] string
        [string] match

        [[ "$string" == "$match"* ]]
        return $?
    }

    static String.EndsWith() {
        [string] string
        [string] match

        [[ "$string" == *"$match" ]]
        return $?
    }

    method String::GetSanitizedVariableName() {
        String.GetSanitizedVariableName "$($this)"
    }

    method String::RegexMatch() {
        [string] regex
        [string] param

        String.RegexMatch "$($this)" "$regex" "$param"
    }

}

class:ImmutableString() {
    extends String

    method ImmutableString::__constructor__() {
        #[ $1 = '=' ] && shift
        Var::__setter__ "$@"
    }

    method ImmutableString::__setter__() {
        throw "$this is immutable"
    }
}
