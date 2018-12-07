dotenv () {
  envfile="${1:-$(pwd)}/.env"

  if [[ -f "$envfile" ]]
  then
    export $(egrep -v '^#' "$envfile" | xargs)
  fi
}

dotenv
