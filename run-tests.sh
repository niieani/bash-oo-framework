#!/usr/bin/env bash

__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/boilerplate.sh"

#Log.Debug:Enable 3
import lib/types/base
import lib/types/ui

import tests/types/test

it 'should print a colorful message'
try
    hexDump="0000000 1b 5b 30 3b 33 32 6d 48 65 6c 6c 6f 21 1b 5b 30"
    message=$(echo $(UI.Color.Green)Hello!$(UI.Color.Default) | hexdump | head -1)
    [[ "$hexDump" = "$message" ]]
finish

it 'should make an instance of an Object'
try
    Object anObject
finish

it 'should make an instance of a number'
try
    Number aNumber
    Object.Exists aNumber
finish

it 'should have destroyed the previous instance'
try
    ! Object.Exists aNumber
finish

it 'should make an instance of a number and initialize with 5'
try
    Number aNumber = 5
    aNumber.Equals 5
finish

it 'should make a number and change its value'
try
    Number aNumber = 10
    aNumber = 12
    aNumber.Equals 12
finish

#echo "${__oo__importedFiles[@]}"
#
#it 'should fail'
#try
#    false
#finish

it "is playing der saxomophone! $(UI.Powerline.Saxophone)"
try
    sleep 1
finish
#echo $(UI.Powerline.ThumbsUp) All tests completed succesfully.

#import tests/types/examples
#import tests/core-test
