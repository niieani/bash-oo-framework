import ../../type-core
import Var

class:String() {
    extends Var

    static String.GetSanitizedVariableName() {
        @mixed input
        @@map

        local clean="${input//[^a-zA-Z0-9]/_}"
        echo "${clean^^}"
    }

    static String.TabsForSpaces() {
        @mixed input
        # TODO: @mixed spaceCount=4
        @@map

        # hardcoded 1 tab = 4 spaces
        echo "${input//[	]/    }"
    }

    static String.RegexMatch() {
        @mixed text; @mixed regex; @mixed param
        @@map

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
        @mixed text
        @@map

        # note: you shouldn't mix tabs and spaces, we explicitly don't count tabs here
        local spaces="$(String.RegexMatch "$text" "^[	]*([ ]*)[.]*" 1)"
        echo "${#spaces}"
    }

    static String.Trim() {
        @mixed text
        @@map

        echo "$(String.RegexMatch "$text" "^[ 	]*(.*)" 1)"
        #text="${text#"${text%%[![:space:]]*}"}"   # remove leading whitespace characters
        #text="${text%"${text##*[![:space:]]}"}"   # remove trailing whitespace characters
        #echo -n "$text"
    }

    static String.Contains() {
        @mixed string
        @mixed match

        [[ "$string" == *"$match"* ]]
        return $?
    }

    static String.StartsWith() {
        @mixed string
        @mixed match

        [[ "$string" == "$match"* ]]
        return $?
    }

    static String.EndsWith() {
        @mixed string
        @mixed match

        [[ "$string" == *"$match" ]]
        return $?
    }

    method String::GetSanitizedVariableName() {
        String.GetSanitizedVariableName "$($this)"
    }

    method String::RegexMatch() {
        @mixed regex; @mixed param
        @@map

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
