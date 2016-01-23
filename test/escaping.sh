#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

echoedEscapes() {
  string escapes='hey \" dude \" \"   cool \\ \\ awesome \\'
  array someArray=( "$escapes" )
  
  [[ "$(someArray forEach 'printf %s "$escapes"')" == "$escapes" ]]

  # printf %s "${escapes}"
  # someArray forEach 'printf "$item"'
  # someArray forEach '>&2 printf "$item"'
}

strings() {
  string temp='this is a "string"  to be \jsonized\.'
  temp getCharCode
  echo
  temp forEachChar 'printf "$char"'
  echo
  temp toJSON
  echo
}

# strings

echoedEscapes