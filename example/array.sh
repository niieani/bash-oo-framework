#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

import lib/system/oo

Log::AddOutput oo/type CUSTOM

manipulatingArrays() {
  array exampleArrayA
  array exampleArrayB
  
  exampleArrayA push 'one'
  exampleArrayA push 'two'
  
  exampleArrayA toString
  exampleArrayA toJSON
}

passingArrays() {
  
  passingArraysInput() {
    [array] passedInArray
    
    passedInArray : \
      { map 'echo "${index} - $(item)"' } \
      { forEach 'item toUpper' }
      
    passedInArray push 'will work only for references'
  }
  
  array someArray=( 'one' 'two' )

  echo 'passing by $var:'
  ## 2 ways of passing a copy of an array (passing by it's definition)
  passingArraysInput "$(someArray)"
  passingArraysInput $var:someArray
  
  ## no changes yet
  someArray toJSON
  
  echo
  echo 'passing by $ref:'
  
  ## in bash >=4.3, which supports references, you may pass by reference
  ## this way any changes done to the variable within the function will affect the variable itself
  passingArraysInput $ref:someArray
  
  ## should show changes
  someArray toJSON
}

## RUN IT:
manipulatingArrays
passingArrays