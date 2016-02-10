#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/namedParameters util/class

class:Human() {
  public string name
  public integer height
  public array eaten

  Human.__getter__() {
    echo "I'm a human called $(this name), $(this height) cm tall."
  }

  Human.Example() {
    [array]     someArray
    [integer]   someNumber
    [...rest]   arrayOfOtherParams

    echo "Testing $(var: someArray toString) and $someNumber"
    echo "Stuff: ${arrayOfOtherParams[*]}"

    # returning the first passed in array
    @return someArray
  }

  Human.Eat() {
    [string] food

    this eaten push "$food"

    # will return a string with the value:
    @return:value "$(this name) just ate $food, which is the same as $1"
  }

  Human.WhatDidHeEat() {
    this eaten toString
  }

  # this is a static method, hence the :: in definition
  Human::PlaySomeJazz() {
    echo "$(UI.Powerline.Saxophone)"
  }
}

# required to initialize the class
Type::Initialize Human

# create an object called 'Mark' of type Human
Human Mark

# call the string.= (setter) method
$var:Mark name = 'Mark'

# call the integer.= (setter) method
$var:Mark height = 180

# adds 'corn' to the Mark.eaten array and echoes the output
$var:Mark Eat 'corn'

# adds 'blueberries' to the Mark.eaten array and echoes the uppercased output
$var:Mark : { Eat 'blueberries' } { toUpper }

# invoke the getter
$var:Mark


## singleton

class:SingletonExample() {
  private integer YoMamaNumber = 150

  SingletonExample.PrintYoMama() {
    echo "Number is: $(this YoMamaNumber)!"
  }
}

# required to initialize the static class
Type::InitializeStatic SingletonExample

# invoke the method on the static instance of SingletonExample
SingletonExample PrintYoMama
