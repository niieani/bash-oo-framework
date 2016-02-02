#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/log util/type
Log::AddOutput util/type CUSTOM

manipulatingArrays() {
  array exampleArrayA
  array exampleArrayB

  $var:exampleArrayA push 'one'
  $var:exampleArrayA push 'two'

  # above is equivalent to calling:
  #   var: exampleArrayA push 'two'
  # or using native bash
  #   exampleArrayA+=( 'two' )

  $var:exampleArrayA toString
  $var:exampleArrayA toJSON
}

passingArrays() {

  passingArraysInput() {
    [array] passedInArray

    $var:passedInArray : \
      { map 'echo "${index} - $(var: item)"' } \
      { forEach 'var: item toUpper' }

    $var:passedInArray push 'will work only for references'
  }

  array someArray=( 'one' 'two' )

  echo 'passing by $var:'
  ## 2 ways of passing a copy of an array (passing by it's definition)
  passingArraysInput "$(var: someArray)"
  passingArraysInput $var:someArray

  ## no changes yet
  $var:someArray toJSON

  echo
  echo 'passing by $ref:'

  ## in bash >=4.3, which supports references, you may pass by reference
  ## this way any changes done to the variable within the function will affect the variable itself
  passingArraysInput $ref:someArray

  ## should show changes
  $var:someArray toJSON
}

## RUN IT:
manipulatingArrays
passingArrays
