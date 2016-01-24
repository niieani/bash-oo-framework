#!/usr/bin/env bash

#__INTERNAL_LOGGING__=true
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

#namespace seamless

Log::AddOutput oo/type CUSTOM
Log::AddOutput error ERROR

import lib/system/oo
import lib/type/util/test

## TODO: import github:niieani/whatever/lalala

class:Human() {
  public string firstName
  public string lastName = 'Lastnameovitch'
  public array children
  public Human child
  public boolean hasSomething
  private string privTest = "someVal"

  Human.test() {
    @resolve:this
    @return:value "children: $(this children)"
  }

  Human.shout() {
    @resolve:this

    this firstName = "$(this firstName) shout!"
    this children push 'shout'
    local a=$(this test)

    @return a
  }

  Human.accessPriv() {
    @resolve:this
    this privTest = "$(this privTest) - changed"
    @return:value $(this privTest)
  }

}

Type::Initialize Human
#Type::Initialize Human static

function testStatic() {
  Human lastName
}

#testStatic

function test2() {
  array hovno
  hovno push one
  hovno push two
  hovno
}

#test2

function testParamPassing() {
  [string] first
  [string] second
  [integer] number

  first toUpper
  second
  number
}

#testParamPassing 'one' 'two' 99

function testBoolean() {
  boolean empty
  boolean presetTrue=true
  boolean presetFalse=false
  boolean presetUnrecognized=blabla

  echo bool default: $empty
  echo bool true: $presetTrue
  echo bool false: $presetFalse
  echo bool blabla: $presetUnrecognized

  empty = true
  echo bool default: $empty

  empty
}

#testBoolean


function testBooleanInClass() {
  Human guy
  guy
  guy hasSomething toString
  guy hasSomething = true
  guy hasSomething toString
#  guy
}

#testBooleanInClass

function testPassingAsParameterSimple() {
  [string] str
  declare -p str
}

#testPassingAsParameterSimple 'hello!'

function testPassingAsParameter() {
  [map] someMap
  [string] str
  [boolean] bool=true
  [Human] theHuman
#  @required [string] last

  declare -p someMap
  declare -p str
  declare -p bool
  declare -p theHuman
}

function testPassingAsParameterCall() {
  declare -A aMap=( [hoho]="yes  m'aam" )
  declare -p aMap

  Human someHuman
#  declare -p someHuman
#  declare -f someHuman || true
  testPassingAsParameter "$(@get aMap)" 'string' false "$(someHuman)"

  string after # GC
}

testPassingAsParameterCall

function testArrayMethods() {
  array someArr=( 1 2 three 4 )

  someArr push '5' 'six'
  someArr forEach 'echo yep-$(item)'
  someArr map 'echo $($var:item toUpper)'

  someArr : { map 'echo $($var:item toUpper)' } { forEach 'echo yep-$($var:item)' }

  someArr : \
    { map 'echo $($var:item toUpper)' } \
    { forEach 'echo yep-$(item)' }
}

#testArrayMethods

function testPrivate() {
  Human yeah

  yeah lastName
  yeah accessPriv

  try {
    yeah privTest = yo
  }
  catch {
    echo private - OK
  }
  try {
    yeah privTest
  }
  catch {
    echo private - OK
  }
}

#testPrivate
