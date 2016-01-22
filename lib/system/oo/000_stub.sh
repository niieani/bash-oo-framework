String::SanitizeForVariableName() {
  local type="$1"
  echo "${type//[^a-zA-Z0-9]/_}"
}

Function::InjectCode() {
  local functionName="$1"
  local injectBefore="$2"
  local injectAfter="$3"
  local body=$(declare -f "$functionName")
  body="${body#*{}" # trim start
  body="${body%\}}" # trim end
  local enter=$'\n'
  eval "${functionName}() { ${enter}${injectBefore}${body}${injectAfter}${enter} }"
}

Function::GetAllStartingWith() {
  local startsWith="$1"
  compgen -A 'function' "$startsWith" || true
}
