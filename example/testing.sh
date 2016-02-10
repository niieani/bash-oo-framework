#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/exception util/log util/type util/test
Log::AddOutput util/type CUSTOM

describe 'Operations on primitives'
  it 'should make a number and change its value using the setter'
  try
    integer aNumber=10
    $var:aNumber = 12
    [[ $aNumber -eq 12 ]]
  expectPass

  it "should make basic operations on two arrays"
  try
    array Letters
    array Letters2

    $var:Letters push "Hello Bobby"
    $var:Letters push "Hello Maria"

    $var:Letters contains "Hello Bobby"
    $var:Letters contains "Hello Maria"

    $var:Letters2 push "Hello Midori,
                        Best regards!"

    $var:Letters2 concatPush $var:Letters
    $var:Letters2 contains "Hello Bobby"
  expectPass
summary
