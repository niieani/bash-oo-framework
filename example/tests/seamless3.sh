#!/usr/bin/env bash

#__INTERNAL_LOGGING__=true
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

namespace seamless

Log::AddOutput seamless CUSTOM
Log::AddOutput error ERROR

import lib/system/oo

#Log::AddOutput oo/parameters-executing CUSTOM


# ------------------------ #



# ------------------------ #



# there could be a variable "modifiedThis", 
# which is set to "Variable::PrintDeclaration this"
# so we kind of have two returns, one real one, 
# and one for the internal change
#
# this way:
# someMap set a 30
#
# would actually update someMap
# and manual rewriting: someMap=$(someMap set a 30)
# would not be required 

# declare __integer_fingerprint=2D6A822E36884C70843578D37E6773C4
# declare __integer_array_fingerprint=2884B8F8E6774006AD0CA1BD4518E093











################

class:Human() {
  public string firstName
  public string lastName = 'Lastnameovitch'
  public array children
  public Human child
  
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

# class:Human
# alias Human="_type=Human trapAssign declare -A"

# DONE: special overriden 'echo' and 'printf' function in methods that saves to a variable

function test1() {
  string justDoIt="yes!"
  map ramda=([test]=ho [great]=ok [test]="\$result ''ha'  ha" [enter]=$(printf "\na\nb\n"))
  
  # monad=true ramda set [ "one" "yep" ]
  ramda set "one" "yep"
  ramda set 'two' "oki  dokies"
  ramda delete enter
  ramda delete test
  ramda
  ramda get 'one'
  ramda : { get 'one' } { toUpper }
  
  # ramda : get [ 'one' ] | string.toUpper
  # ramda { get 'one' } { toUpper }
  
  ramda set 'one' "$(ramda '{' get 'one' } '{' toUpper })"
  ramda
  
  map polio=$(ramda)
  
  map kwiko=$(polio | monad=true map.set "kwiko" "liko")
  kwiko
  map kwiko=$(polio | monad=true map.set "kwiko" "kombo")
  kwiko
  
  justDoIt toUpper
}

# test1

function test2() {
  array hovno
  hovno push one
  hovno push two
  hovno
}

# test2 

function test3() {
  map obj=([__object_type]=Human [firstName]=Bazyli)
  declare -p obj
  obj firstName
}

# test3

function test4() {
  Human obj
  obj firstName = Ivon
  declare -p obj
  obj firstName
}

# test4

function test5() {
  Human obj
  obj children push '  "a"  b  c  '
  obj children push "123 $(printf "\ntest")"
  # declare -p obj
  obj children
}

# test5

function test6() {
  Human obj
  obj child firstName = "Ivon \" $(printf "\ntest") 'Ivonova'"
  obj child firstName
  # declare -p obj
}

# test6

function test7() {
  Human obj
  obj child child child children push '  "a"  b  c  '
  
  # obj { child child child children push 'abc' } { get 'abc' } { toUpper }
  
  test "$(obj child child child children)" == '([0]="  \"a\"  b  c  ")'
  declare -p obj
}

# test7

function test8() {
  Human obj
  
  # obj firstName = [ Bazyli ]
  obj : { firstName = Bazyli } { toUpper }
  # obj firstName = Bazyli
  
  obj shout
  obj shout
  
  # declare -p obj
}

# test8

function test9() {
  array hovno
  hovno : { push one }
  hovno push two
  hovno
}

# test9

function test10() {
  Human obj
  
  obj child child firstName = SuperBazyli
  local apostrophe="'"
  obj child child child child child child firstName = 'Bazyli " \\ '$apostrophe' " Brzoska'
  
  obj child child child child child child firstName
  obj child child child child child child
  
  # obj
  
  # declare -p obj
  # obj
}

# test10


class:PropertiesTest() {
  # http://askubuntu.com/questions/366103/saving-more-corsor-positions-with-tput-in-bash-terminal
	
	private integer x
	
  PropertiesTest.set() {
    @resolve:this
    [integer] value
    
    echo -en "\E[6n"
read -sdR CURPOS
CURPOS=${CURPOS#*[}
    
    this x = $value
    
    @return
  }
  
  # PropertiesTest.capture() {
  #   @resolve:this
    
    
  #   this x
    
  #   @return
  # }
  
  PropertiesTest.get() {
    @resolve:this
    
    this x
    
    @return
  }
}

Type::Initialize PropertiesTest


function testProperties() {
  PropertiesTest obj
  
  # obj set 123
  # obj capture
  obj get
}

# testProperties

## TODO: parametric versions of string/integer/array functions
## they could either take the variable name as param or [string[]]

## obj firstname = Bazyli
## arr @ push Bazyli
## obj @ firstname = Bazyli

###########################

function testCursor() {
  UI.Cursor cursor
  
  cursor capture
  
  echo "lol- x: $(cursor x) | y: $(cursor y)"
  echo haha
  
  sleep 1
  
  cursor restore 2
  
  echo lila
  echo
}

# testCursor

boolean.__getter__() {
  : ## TODO implement getters (they're executed instead of @get if executed directly)
}

## TODO: save UUID prefix for numbers (or maybe not!)



## TEST LIB

testtest() {
  Test newGroup "Objects"
  
  it 'should work'
  try
    fail
  expectPass
  
  Test displaySummary
}

testtest

# local -A somehuman=$(new Human)
# new Human

