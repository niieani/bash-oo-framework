#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-bootstrap.sh"

## MAIN ##
import util/log util/exception util/tryCatch util/namedParameters util/class
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

# lala

lala2() {
  [string] something=yo

  echo $something

  UI.Cursor cursor
  $var:cursor capture
  echo yo
  sleep 1
  $var:cursor restore
  echo yopa
}

lala2


## YOUR CODE GOES HERE ##
