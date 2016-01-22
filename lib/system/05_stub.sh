namespace oo

Array::Contains() {
    local e
    for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done
    return 1
}

String::IsNumber() {
    local input="$1"

    local regex='^-?[0-9]+([.][0-9]+)?$'
    if ! [[ "$input" =~ $regex ]]
    then
        return 1
    fi
    return 0
}

String::GenerateSpaces() {
    local howMany="$1"

    if [[ "$howMany" -gt 0 ]]
    then
        ( printf "%*s" "$howMany" )
    fi
}

String::ReplaceSlashes() {
    local stringToMark="$1"
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slash$slash/$slashReplacement}"
}

String::RestoreSlashes() {
    local stringToMark="$1"

    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slashReplacement/$slash}"
}

Command::GetType() {
    local name="$1"
    local typeMatch=$(type -t "$name" 2> /dev/null || true)
    echo "$typeMatch"
}

Command::Exists(){
    local name="$1"
    local typeMatch=$(type -t "$name" 2> /dev/null || true)
    [[ "$typeMatch" == "alias" || "$typeMatch" == "function" || "$typeMatch" == "builtin" ]]
}

Alias::Exists(){
    local name="$1"
    local typeMatch=$(type -t "$name" 2> /dev/null || true)
    [[ "$typeMatch" == "alias" ]]
}

Function::Exists(){
    local name="$1"
    declare -f "$name" &> /dev/null
}