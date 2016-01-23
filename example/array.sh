#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

import lib/system/oo

Log::AddOutput oo/type CUSTOM

manipulatingArrays() {
  array exampleArrayA
  array exampleArrayB

  $var:exampleArrayA push 'one'
  $var:exampleArrayA push 'two'

  $var:exampleArrayA toString
  $var:exampleArrayA toJSON
}

passingArrays() {
  
  passingArraysInput() {
    [array] passedInArray

    $var:passedInArray : \
      { map 'echo "${index} - $($var:item)"' } \
      { forEach '@ item toUpper' }

    $var:passedInArray push 'will work only for references'
  }
  
  array someArray=( 'one' 'two' )

  echo 'passing by $var:'
  ## 2 ways of passing a copy of an array (passing by it's definition)
  passingArraysInput "$(someArray)"
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
#passingArrays
