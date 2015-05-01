#!/usr/bin/env bash

source oo.sh
oo:import tests/types/test

it 'should print a colorful message'
try
    hexDump="0000000 1b 5b 30 3b 33 32 6d 48 65 6c 6c 6f 21 1b 5b 30"
    message=$(echo $(UI.Color.Green)Hello!$(UI.Color.Default) | hexdump | head -1)
    [[ "$hexDump" = "$message" ]]
finish

it 'should make an instance of an Object'
try
#    set -v
#    set -x
    #oo:debug:enable 3
    Object anObject
    #oo:debug:disable
#    set +v
#    set +x
    #isMethodDeclared aNumber
finish

it 'should make an instance of a number'
try
    Number aNumber
    oo:isDeclared aNumber
finish

it 'should make an instance of a number and initialize with 10'
try
    Number aNumber = 10
    #aNumber.Equals 10
finish

it "should make a number and change it's value"
try
    Number aNumber = 10
    aNumber = 12
    aNumber.Equals 12
finish

#it 'should fail'
#try
#    false
#finish

#it 'is playing on a saxomophone!'
#try
#    sleep 1
#    UI.Powerline.Saxophone
#    echo
#finish
#echo $(UI.Powerline.ThumbsUp) All tests completed succesfully.

#oo:import tests/types/examples
#oo:import tests/core-test
