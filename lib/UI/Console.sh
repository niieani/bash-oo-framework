import UI/Color

Console::WriteStdErr() {
  # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
  cat <<< "$*" 1>&2
  return
}

Console::WriteStdErrAnnotated() {
  local script="$1"
  local lineNo=$2
  local color=$3
  local type=$4
  shift; shift; shift; shift

  Console::WriteStdErr "$color[$type] $(UI.Color.Blue)[${script}:${lineNo}]$(UI.Color.Default) $* "
}
