#!/usr/bin/env bash

#__INTERNAL_LOGGING__=true
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

#namespace seamless

Log::AddOutput oo/type CUSTOM
Log::AddOutput error ERROR

import lib/system/oo


class:Human() {
  public string firstName
  public string lastName = 'Lastnameovitch'
  public array children
  public Human child
  public boolean hasSomething

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
}

Type::Initialize Human


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

testBooleanInClass