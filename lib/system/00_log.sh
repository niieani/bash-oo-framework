Log.WriteToStdErr() {
    # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
    cat <<< "$*" 1>&2
    return 0
}

Log.Write() {
    # TODO: make a switch and support more outputs
    if test "${__oo__logger}" = "STDERR"
    then
        Log.WriteToStdErr "$@"
    fi
    return 0
}

Log.Debug.Write() {
    local script="${BASH_SOURCE[1]##*/}"
#    script="${script##*/}"
    #local script=${BASH_SOURCE[1]}
    #local prefix='./'
    #script="${script#$prefix}"
    local lineNo=${BASH_LINENO[1]}
    local type=${1:-DEBUG}
    local color=${2:-$'\033[0;33m'}
    local level=${3:-0}
    shift; shift; shift;

    if [[ ! -z $level ]] || [[ ! -z $__oo__debug ]] && [[ $__oo__debug -ge $level ]]
    then
#        if Function.Exists UI.Color.Default
#        then
            Log.Write "$color[$type:$level] $(UI.Color.Default)$* $(UI.Color.Blue)[${script}:${lineNo}]$(UI.Color.Default)"
#        else
#            Log.Write "[${script}:${lineNo}] [$type] $*"
#        fi
    fi
}

alias Log.Debug="Log.Debug.Write 'DEBUG' $'\033[0;33m'"
alias Log.Error="Log.Debug.Write 'ERROR' $'\033[0;33m'"
alias Log.Info="Log.Debug.Write 'INFO' $'\033[0;33m'"
alias Log.Warn="Log.Debug.Write 'WARN' $'\033[0;33m'"

Log.Debug.SetLevel() {
    declare -ig "__oo__debug=${1:-1}"
}
alias Log.Debug.Disable="unset '__oo__debug'"
