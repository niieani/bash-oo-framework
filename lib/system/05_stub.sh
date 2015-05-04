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
