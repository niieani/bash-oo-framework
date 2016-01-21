String::SanitizeForVariableName() {
  local type="$1"
  echo "${type//[^a-zA-Z0-9]/_}"
}
