namespace util/exception
import String/GetSpaces String/SlashReplacement UI/Color UI/Console

#########################
### HANDLE EXCEPTIONS ###
#########################

trap "__EXCEPTION_TYPE__=\"\$_\" command_not_found_handle \$? \$BASH_COMMAND" ERR
set -o errtrace  # trace ERR through 'time command' and other functions

# unalias throw 2> /dev/null || true
unset -f throw 2> /dev/null || true
alias throw="__EXCEPTION_TYPE__=\${e:-Manually invoked} command_not_found_handle"

Exception::CustomCommandHandler() {
  ## this method can be overridden to create a custom, unknown command handler
  return 1
}

Exception::FillExceptionWithTraceElements() {
  local IFS=$'\n'
  for traceElement in $(Exception::DumpBacktrace ${skipBacktraceCount:-3})
  do
    exception+=( "$traceElement" )
  done
}

command_not_found_handle() {
  # USE DEFAULT IFS IN CASE IT WAS CHANGED
  local IFS=$' \t\n'

  # ignore the error from the catch subshell itself
  if [[ "$*" = '( set -'*'; true'* ]] ## TODO: refine with a regex and test
  then
    return 0
  fi

  Exception::CustomCommandHandler "$@" && return 0 || true

  local exit_code="${1}"
  shift || true # there might have not been any parameter, in which case "shift" would fail
  local script="${BASH_SOURCE[1]#./}"
  local lineNo="${BASH_LINENO[0]}"
  local undefinedObject="$*"
  local type="${__EXCEPTION_TYPE__:-"Undefined command"}"

  if [[ "$undefinedObject" == "("*")" ]]
  then
    type="Subshell returned a non-zero value"
  fi

  if [[ -z "$undefinedObject" ]]
  then
    undefinedObject="$type"
  fi

  if [[ $__oo__insideTryCatch -gt 0 ]]
  then
    subject=level3 Log "inside Try No.: $__oo__insideTryCatch"

    if [[ ! -s $__oo__storedExceptionLineFile ]]; then
      echo "$lineNo" > $__oo__storedExceptionLineFile
    fi
    if [[ ! -s $__oo__storedExceptionFile ]]; then
      echo "$undefinedObject" > $__oo__storedExceptionFile
    fi
    if [[ ! -s $__oo__storedExceptionSourceFile ]]; then
      echo "$script" > $__oo__storedExceptionSourceFile
    fi
    if [[ ! -s $__oo__storedExceptionBacktraceFile ]]; then
      Exception::DumpBacktrace 2 > $__oo__storedExceptionBacktraceFile
    fi

    return 1 # needs to be return 1
  fi

  if [[ $BASH_SUBSHELL -ge 25 ]] ## TODO: configurable
  then
    echo "ERROR: Call stack exceeded (25)."
    Exception::ContinueOrBreak || exit 1
  fi

  local -a exception=( "$lineNo" "$undefinedObject" "$script" )

  Exception::FillExceptionWithTraceElements

  Console::WriteStdErr
  Console::WriteStdErr " $(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Bold)UNCAUGHT EXCEPTION: $(UI.Color.LightRed)${type} $(UI.Color.Yellow)$(UI.Color.Italics)(${exit_code})$(UI.Color.Default)"
  Exception::PrintException "${exception[@]}"

  Exception::ContinueOrBreak
}

Exception::PrintException() {
  #    [...rest] exception
  local -a exception=("$@")

  local -i backtraceIndentationLevel=${backtraceIndentationLevel:-0}

  local -i counter=0
  local -i backtraceNo=0

  local -a backtraceLine
  local -a backtraceCommand
  local -a backtraceFile

  #for traceElement in Exception::GetLastException
  while [[ $counter -lt ${#exception[@]} ]]
  do
    backtraceLine[$backtraceNo]="${exception[$counter]}"
    counter+=1
    backtraceCommand[$backtraceNo]="${exception[$counter]}"
    counter+=1
    backtraceFile[$backtraceNo]="${exception[$counter]}"
    counter+=1

    backtraceNo+=1
  done

  local -i index=1

  while [[ $index -lt $backtraceNo ]]
  do
    Console::WriteStdErr "$(Exception::FormatExceptionSegment "${backtraceFile[$index]}" "${backtraceLine[$index]}" "${backtraceCommand[($index - 1)]}" $(( $index + $backtraceIndentationLevel )) )"
    index+=1
  done
}

Exception::CanHighlight() {
  #    [string] errLine
  #    [string] stringToMark
  local errLine="$1"
  local stringToMark="$2"

  local stringToMarkWithoutSlash="$(String::ReplaceSlashes "$stringToMark")"
  errLine="$(String::ReplaceSlashes "$errLine")"

  if [[ "$errLine" == *"$stringToMarkWithoutSlash"* ]]
  then
    return 0
  else
    return 1
  fi
}

Exception::HighlightPart() {
  #    [string] errLine
  #    [string] stringToMark
  local errLine="$1"
  local stringToMark="$2"

  # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
  local stringToMarkWithoutSlash="$(String::ReplaceSlashes "$stringToMark")"
  errLine="$(String::ReplaceSlashes "$errLine")"

  local underlinedObject="$(Exception::GetUnderlinedPart "$stringToMark")"
  local underlinedObjectInLine="${errLine/$stringToMarkWithoutSlash/$underlinedObject}"

  # Bring back the slash:
  underlinedObjectInLine="$(String::RestoreSlashes "$underlinedObjectInLine")"

  # Trimming:
  underlinedObjectInLine="${underlinedObjectInLine#"${underlinedObjectInLine%%[![:space:]]*}"}" # "

  echo "$underlinedObjectInLine"
}

Exception::GetUnderlinedPart() {
  #    [string] stringToMark
  local stringToMark="$1"

  echo "$(UI.Color.LightGreen)$(UI.Powerline.RefersTo) $(UI.Color.Magenta)$(UI.Color.Underline)$stringToMark$(UI.Color.White)$(UI.Color.NoUnderline)"
}

Exception::FormatExceptionSegment() {
  local script="$1"
  local -i lineNo="$2"
  local stringToMark="$3"
  local -i callPosition="${4:-1}"
  #    [string] script
  #    [integer] lineNo
  #    [string] stringToMark
  #    [integer] callPosition=1

  local errLine="$(sed "${lineNo}q;d" "$script")"
  local originalErrLine="$errLine"

  local -i linesTried=0

  ## TODO: when line ends with slash \ it is a multiline statement
  ## TODO: when eval or alias
  # In case it's a multiline eval, sometimes bash gives a line that's offset by a few
  while [[ $linesTried -lt 5 && $lineNo -gt 0 ]] && ! Exception::CanHighlight "$errLine" "$stringToMark"
  do
    linesTried+=1
    lineNo+=-1
    errLine="$(sed "${lineNo}q;d" "$script")"
  done

  # Cut out the path, leave the script name
  script="${script##*/}"

  local prefix="   $(UI.Powerline.Branch)$(String::GetSpaces $(($callPosition * 3 - 3)) || true) "

  if [[ $linesTried -ge 5 ]]
  then
    # PRINT THE ORGINAL OBJECT AND ORIGINAL LINE #
    #local underlinedObject="$(Exception::HighlightPart "$errLine" "$stringToMark")"
    local underlinedObject="$(Exception::GetUnderlinedPart "$stringToMark")"
    echo "${prefix}$(UI.Color.White)${underlinedObject}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
    prefix="$prefix$(UI.Powerline.Fail) "
    errLine="$originalErrLine"
  fi

  local underlinedObjectInLine="$(Exception::HighlightPart "$errLine" "$stringToMark")"

  echo "${prefix}$(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
}

Exception::ContinueOrBreak() (
  ## TODO: Exceptions that happen in commands that are piped to others do not HALT the execution
  ## TODO: Add a workaround for this ^
  ## probably it's enough to -pipefail, check for a pipe in command_not_found - and if yes - return 1

  # if in a terminal
  if [ -t 0 ]
  then
    trap "stty sane; exit 1" INT
    Console::WriteStdErr
    Console::WriteStdErr " $(UI.Color.Yellow)$(UI.Powerline.Lightning)$(UI.Color.White) Press $(UI.Color.Bold)[CTRL+C]$(UI.Color.White) to exit or $(UI.Color.Bold)[Return]$(UI.Color.White) to continue execution."
    read -s
    Console::WriteStdErr "$(UI.Color.Blue)$(UI.Powerline.Cog)$(UI.Color.White)  Continuing...$(UI.Color.Default)"
    return 0
  else
    Console::WriteStdErr
    exit 1
  fi
)

Exception::DumpBacktrace() {
  local -i startFrom="${1:-1}"
  #    [integer] startFrom=1
  # inspired by: http://stackoverflow.com/questions/64786/error-handling-in-bash

  # USE DEFAULT IFS IN CASE IT WAS CHANGED
  local IFS=$' \t\n'

  local -i i=0

  while caller $i > /dev/null
  do
    if (( $i + 1 >= $startFrom ))
    then
      local -a trace=( $(caller $i) )

      echo "${trace[0]}"
      echo "${trace[1]}"
      echo "${trace[@]:2}"
    fi
    i+=1
  done
}
