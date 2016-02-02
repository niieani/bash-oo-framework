#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/log util/type
Log::AddOutput util/type CUSTOM

regex() {
  # create a string someString
  string someString="My 123 Joe is 99 Mark"

  # saves all matches and their match groups for the said regex:
  array matchGroups=$($var:someString getMatchGroups '([0-9]+) [a-zA-Z]+')

  # lists all matches in group 1:
  $var:matchGroups every 2 1

  ## group 0, match 1
  $var:someString match '([0-9]+) [a-zA-Z]+' 0 1

  # calls the getter - here it prints the value
  $var:someString
}

regex
