Array.Contains() {
    local e
    for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done
    return 1
}

String.GetXSpaces() {
    @var howMany

    if [[ "$howMany" -gt 0 ]]
    then
        ( printf "%*s" "$howMany" )
    fi
    return 0
}

Function.Exists(){
    local name="$1"
    local typeMatch=$(type "$name" 2> /dev/null) || return 1
    echo "$typeMatch" | grep "function\|alias" &> /dev/null || return 1
    return 0
}
alias Object.Exists="Function.Exists"
