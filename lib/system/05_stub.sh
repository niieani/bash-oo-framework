namespace oo

Array.Contains() {
    local e
    for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done
    return 1
}

String.IsNumber() {
    @var input

    local regex='^-?[0-9]+([.][0-9]+)?$'
    if ! [[ "$input" =~ $regex ]]
    then
        return 1
    fi
    return 0
}

String.GetXSpaces() {
    @var howMany

    if [[ "$howMany" -gt 0 ]]
    then
        ( printf "%*s" "$howMany" )
    fi
    return 0
}

String.ReplaceSlashes() {
    @var stringToMark
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slash$slash/$slashReplacement}"
}

String.BringBackSlashes() {
    @var stringToMark
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slashReplacement/$slash}"
}

Function.Exists(){
    local name="$1"
    local typeMatch=$(type "$name" 2> /dev/null) || return 1
    echo "$typeMatch" | grep "function\|alias" &> /dev/null || return 1
    return 0
}
alias Object.Exists="Function.Exists"
