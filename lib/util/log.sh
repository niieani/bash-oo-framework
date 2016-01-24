import util/bash4
import UI/Color UI/Console

declare -Ag __oo__logScopes
declare -Ag __oo__logScopeOutputs
declare -Ag __oo__logDisabledFilter
declare -Ag __oo__loggers

Log::NameScope() {
  local scopeName="$1"
  local script="${BASH_SOURCE[1]}"
  __oo__logScopes["$script"]="$scopeName"
}

Log::AddOutput() {
  local scopeName="$1"
  local outputType="${2:-STDERR}"
  __oo__logScopeOutputs["$scopeName"]+="$outputType;"
}

Log::ResetOutputsAndFilters() {
  local scopeName="$1"
  unset __oo__logScopeOutputs["$scopeName"]
  unset __oo__logDisabledFilter["$scopeName"]
}

Log::ResetAllOutputsAndFilters() {
  unset __oo__logScopeOutputs
  unset __oo__logDisabledFilter
  declare -Ag __oo__logScopeOutputs
  declare -Ag __oo__logDisabledFilter
}

Log::DisableFilter() {
  __oo__logDisabledFilter["$1"]=true
}

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
      subject="${subject:-LOG}" Log::Using "$logger" "$@"
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
          subject="${subject:-LOG}" Log::Using "$logger" "$@"
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
        subject="${subject:-LOG}" Log::Using "$logger" "$@"
      done
    fi
  fi
}

Log::RegisterLogger() {
  local logger="$1"
  local method="$2"
  __oo__loggers["$logger"]="$method"
}

Log::Using() {
  local logger="$1"
  shift
  if [[ ! -z ${__oo__loggers["$logger"]} ]]
  then
      ${__oo__loggers["$logger"]} "$@"
  fi
}

Logger::DEBUG() {
    Console::WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) DEBUG "$@"
}
Logger::ERROR() {
    Console::WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Red) ERROR "$@"
}
Logger::INFO() {
    Console::WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Blue) INFO "$@"
}
Logger::WARN() {
    Console::WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) WARN "$@"
}
Logger::CUSTOM() {
    Console::WriteStdErr "$(UI.Color.Yellow)[${subject^^}] $(UI.Color.Default)$* "
}
Logger::DETAILED() {
    Console::WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) "${subject^^}" "$@"
}

Log::RegisterLogger STDERR Console::WriteStdErr
Log::RegisterLogger DEBUG Logger::DEBUG
Log::RegisterLogger ERROR Logger::ERROR
Log::RegisterLogger INFO Logger::INFO
Log::RegisterLogger WARN Logger::WARN
Log::RegisterLogger CUSTOM Logger::CUSTOM
Log::RegisterLogger DETAILED Logger::DETAILED

alias namespace="Log::NameScope"
namespace oo/log
