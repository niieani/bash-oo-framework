dotenv () {
  envfile="${1:-$(pwd)}/.env"

  if [[ -f "$envfile" ]]
  then
    IFS=$'\n' locals=( $(egrep -v '^#' "$envfile") )
    IFS=$' \t\n'

    for var in "${locals[@]}"
    do
      export "$var"
    done
  fi
}

dotenv
