#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-framework.sh"

## MAIN ##
import util/log util/exception util/tryCatch util/namedParameters util/classes
import UI/Cursor

# lalala
lala() {
  [string] something=yo

  echo $something

  UI.Cursor cursor
  $var:cursor capture
  echo yo
  sleep 1
  $var:cursor restore
  echo yopa
}

lala



## YOUR CODE GOES HERE ##
