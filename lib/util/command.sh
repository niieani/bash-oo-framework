# no dependencies

Command::GetType() {
  local name="$1"
  local typeMatch=$(type -t "$name" 2> /dev/null || true)
  echo "$typeMatch"
}

Command::Exists(){
  local name="$1"
  local typeMatch=$(Command::GetType "$name")
  [[ "$typeMatch" == "alias" || "$typeMatch" == "function" || "$typeMatch" == "builtin" ]]
}

Alias::Exists(){
  local name="$1"
  local typeMatch=$(Command::GetType "$name")
  [[ "$typeMatch" == "alias" ]]
}

Function::Exists(){
  local name="$1"
  declare -f "$name" &> /dev/null
}

Function::GetAllStartingWith() {
  local startsWith="$1"
  compgen -A 'function' "$startsWith" || true
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
