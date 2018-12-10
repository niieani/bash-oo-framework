dotenv () {
  envfile="${1:-$(pwd)}/.env"
  N='�' # CHR(160)

  if [[ -f "$envfile" ]]
  then
    locals=( $(egrep -v '^#' "$envfile" | tr ' ' "$N" | xargs) )

    for var in "${locals[@]}"
    do
      export "$(echo $var | tr "$N" ' ')"
    done
  fi
}

dotenv
