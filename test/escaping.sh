#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/exception util/class
# import util

echoedEscapes() {
  string escapes='hey \" dude \" \"   cool \\ \\ awesome \\'
  array someArray=( "$escapes" )

  [[ "$(var: someArray forEach 'printf %s "$escapes"')" == "$escapes" ]]

  # printf %s "${escapes}"
  # someArray forEach 'printf "$item"'
  # someArray forEach '>&2 printf "$item"'
}

strings() {
  string temp='this is a "string"  to be \jsonized\.'
  $var:temp getCharCode
  echo
  $var:temp forEachChar 'printf "$char"'
  echo
  $var:temp toJSON
  echo
}

strings

# echoedEscapes
