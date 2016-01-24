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
