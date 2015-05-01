# http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
Log.WriteToStdErr() {
    cat <<< "$*" 1>&2
    return 0
}

Log.Write() {
    test "${__oo__logger}" = "STDERR" && Log.WriteToStdErr "$@"
    return 0
}

Log.Debug.Write() {
    local script="${BASH_SOURCE[1]#./}"
    #local script=${BASH_SOURCE[1]}
    #local prefix='./'
    #script="${script#$prefix}"
    local lineNo=${BASH_LINENO[1]}
    local level=${1:-0}
    local type=${2:-DEBUG}
    local color=${3:-$'\033[0;33m'}
    shift; shift; shift;

    if [[ ! -z $level ]] || [[ ! -z $__oo__debug ]] && [[ $__oo__debug -ge $level ]]
    then
        if Function.Exists UI.Color
        then
            Log.Write "$(UI.Color.Blue)[${script}:${lineNo}] $color[$type] $(UI.Color.White)$*$(UI.Color.Default)"
        else
            Log.Write "[${script}:${lineNo}] [$type] $*"
        fi
    fi
}

unalias Log.Debug
unalias Log.Debug:1
unalias Log.Debug:2
unalias Log.Debug:3
alias Log.Debug="Log.Debug.Write '1' 'DEBUG' $'\033[0;33m'"
alias Log.Debug:1="Log.Debug.Write '1' 'DEBUG' $'\033[0;33m'"
alias Log.Debug:2="Log.Debug.Write '2' 'DEBUG' $'\033[0;33m'"
alias Log.Debug:3="Log.Debug.Write '3' 'DEBUG' $'\033[0;33m'"

Log.Debug:Enable() {
    declare -ig "__oo__debug=${1:-1}"
}

Log.Debug:Disable() {
    unset '__oo__debug'
}
