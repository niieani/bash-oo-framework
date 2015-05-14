Log.Add() {
    local script="${BASH_SOURCE[1]##*/}"
    local lineNo=${BASH_LINENO[1]}
    local type=${1:-DEBUG}
    local color=${2:-$'\033[0;33m'}
    local level=${3:-0}
    local levelGlobalName=__oo__log_${type,,}
    shift; shift; shift;

    if [[ $level -eq 0 ]] || [[ ! -z ${!levelGlobalName} ]] && [[ ${!levelGlobalName} -ge $level ]]
    then
        Console.WriteStdErr "$color[$type:$level] $(UI.Color.Default)$* $(UI.Color.Blue)[${script}:${lineNo}]$(UI.Color.Default)"
    fi
}

alias Log.Debug="Log.Add 'DEBUG' $'\033[0;33m'"
alias Log.Error="Log.Add 'ERROR' $'\033[0;33m'"
alias Log.Info="Log.Add 'INFO' $'\033[0;33m'"
alias Log.Warn="Log.Add 'WARN' $'\033[0;33m'"

Log.SetLevel() {
    local type=${1,,}
    declare -ig "__oo__log_$type=${2:0}"
}

alias Log.Debug.SetLevel="Log.SetLevel DEBUG"
alias Log.Debug.Disable="unset '__oo__log_debug'"

## NEW WAY

declare -Ag __oo__logScopes
declare -Ag __oo__logScopeOutputs
declare -Ag __oo__logDisabledFilter
declare -Ag __oo__loggers

Log.NameScope() {
    local scopeName="$1"
    local script="${BASH_SOURCE[1]}"
    __oo__logScopes["$script"]="$scopeName"
}

Log.AddOutput() {
    local scopeName="$1"
    local outputType="${2:-STDERR}"
    __oo__logScopeOutputs["$scopeName"]+="$outputType;"
    #__oo__logScopeWhiteList+="$scopeName"
}

Log.DisableFilter() {
    __oo__logDisabledFilter["$1"]=true
}

# scope is: FILENAME_OR_SCOPENAME/FUNCTION_OR_SUBSCOPE
# enables whole scope:
# WhiteListScope FILENAME
# enable logging from a specific function
# WhiteListScope FILENAME/FUNCTION

Log() {
    local callingFunction="${FUNCNAME[1]}"
    local callingScript="${BASH_SOURCE[1]}"
    local scope
    if [[ ! -z "${__oo__logScopes["$callingScript"]}" ]]
    then
        scope="${__oo__logScopes["$callingScript"]}"
    else # just the filename without extension
        scope="${callingScript##*/}"
        scope="${scope%.*}"
    fi
    local loggerList
    local loggers
    local logger
    local logged
    
    if [[ ! -z "$subject" ]]
    then
        if [[ ! -z "${__oo__logScopeOutputs["$scope/$callingFunction/$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$callingFunction/$subject"]}"
        elif [[ ! -z "${__oo__logScopeOutputs["$scope/$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$subject"]}"
        elif [[ ! -z "${__oo__logScopeOutputs["$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$subject"]}"
        fi
        
        loggers=( ${loggerList//;/ } )
        for logger in "${loggers[@]}"
        do
            Log.Using "$logger" "$@"
            logged=true
        done
    fi
    
    if [[ ! -z "${__oo__logScopeOutputs["$scope/$callingFunction"]}" ]]
    then
        if [[ -z $logged ]] || [[ ${__oo__logDisabledFilter["$scope/$callingFunction"]} == true || ${__oo__logDisabledFilter["$scope"]} == true ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$callingFunction"]}"
            loggers=( ${loggerList//;/ } )
            for logger in "${loggers[@]}"
            do
                Log.Using "$logger" "$@"
                logged=true
            done
        fi
    fi
    
    if [[ ! -z "${__oo__logScopeOutputs["$scope"]}" ]]
    then
        if [[ -z $logged ]] || [[ ${__oo__logDisabledFilter["$scope"]} == true ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope"]}"
            loggers=( ${loggerList//;/ } )
            for logger in "${loggers[@]}"
            do
                Log.Using "$logger" "$@"
                logged=true
            done
        fi
    fi
}

Log.RegisterLogger() {
    local logger="$1"
    local method="$2"
    __oo__loggers["$logger"]="$method"
}

Log.Using() {
    local logger="$1"
    shift
    if [[ ! -z ${__oo__loggers["$logger"]} ]]
    then
        eval ${__oo__loggers["$logger"]} "$@"
    fi
}

Console.WriteStdErr() {
    # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
    cat <<< "$*" 1>&2
    return 0
}

Console.WriteStdErrAnnotated() {
    local script="$1"
    local lineNo=$2
    local color=$3
    local type=$4
    shift; shift; shift; shift

    Console.WriteStdErr "$color[$type] $(UI.Color.Default)$* $(UI.Color.Blue)[${script}:${lineNo}]$(UI.Color.Default)"
}

Log.RegisterLogger STDERR Console.WriteStdErr
Log.RegisterLogger DEBUG 'Console.WriteStdErrAnnotated "${BASH_SOURCE[2]##*/}" ${BASH_LINENO[1]} $(UI.Color.Yellow) DEBUG'
Log.RegisterLogger ERROR 'Console.WriteStdErrAnnotated "${BASH_SOURCE[2]##*/}" ${BASH_LINENO[1]} $(UI.Color.Red) ERROR'
Log.RegisterLogger INFO 'Console.WriteStdErrAnnotated "${BASH_SOURCE[2]##*/}" ${BASH_LINENO[1]} $(UI.Color.Blue) INFO'
Log.RegisterLogger WARN 'Console.WriteStdErrAnnotated "${BASH_SOURCE[2]##*/}" ${BASH_LINENO[1]} $(UI.Color.Yellow) WARN'
Log.RegisterLogger CUSTOM 'Console.WriteStdErrAnnotated "${BASH_SOURCE[2]##*/}" ${BASH_LINENO[1]} $(UI.Color.Yellow) ${subject^^}'

