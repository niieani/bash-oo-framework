#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

# Log::AddOutput oo/System::LoadFile CUSTOM
# Log::AddOutput oo/System::LoadFile/level2 VOID
# Log::AddOutput oo CUSTOM
# Log::AddOutput level1 CUSTOM
# Log::AddOutput level2 CUSTOM
# Log::AddOutput level3 CUSTOM
# Log::AddOutput oo/level1 CUSTOM

import lib/type-core
import lib/types/base
import lib/types/ui
import lib/types/util/test

Test.NewGroup "Named Parameters"
it 'should try to assign map the params locally'
try
    testPassingParams() {
        [string] hello
        [string[4]] anArrayWithFourElements

        # note: between 2-10 there are aliases for arrays like [string[4]]
        # after 10 you need to write l=LENGTH [string[]], like this:
        l=2 [string[]] anotherArrayWithTwo

        [string] anotherSingle
        [reference] table
        [...rest] anArrayOfVariedSize

        local thisShouldWork="correct"

        test "$hello" = "$1"
        #
        test "${anArrayWithFourElements[0]}" = "$2"
        test "${anArrayWithFourElements[1]}" = "$3"
        test "${anArrayWithFourElements[2]}" = "$4"
        test "${anArrayWithFourElements[3]}" = "$5"
        #
        test "${anotherArrayWithTwo[0]}" = "$6"
        test "${anotherArrayWithTwo[1]}" = "$7"
        #
        test "$anotherSingle" = "$8"
        #
        test "${table[test]}" = "works"
        table[inside]="adding a new value"
        #
        test "${anArrayOfVariedSize[*]}" = "${*:10}"
        #
        test "$thisShouldWork" = "correct"
    }

    fourElements=( a1 a2 "a3 with spaces" a4 )
    twoElements=( b1 b2 )
    declare -A assocArray
    assocArray[test]="works"

    testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

    test "${assocArray[inside]}" = "adding a new value"

    # run twice, just to be sure we don't leave behind anythinh
    testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

expectPass

Test.DisplaySummary


Test.NewGroup "Objects"

it 'should print a colorful message'
try
    hexDump="0000000 1b 5b 30 3b 33 32 6d 48 65 6c 6c 6f 21 1b 5b 30"
    message=$(echo $(UI.Color.Green)Hello!$(UI.Color.Default) | hexdump | head -1)
    [[ "$hexDump" = "$message" ]]
expectPass

it 'should make an instance of an Object'
try
    Object anObject
    test "$(anObject)" = "[Object] anObject"
expectPass

it 'should make an instance of a number'
try
    Number aNumber
    Function::Exists aNumber
expectPass

it 'should have destroyed the previous instance'
try
    ! Function::Exists aNumber
expectPass

it 'should make an instance of a number and initialize with 5'
try
    Number aNumber = 5
    aNumber.Equals 5
expectPass

it 'should make a number and change its value'
try
    Number aNumber = 10
    aNumber = 12
    # it's possible to compare with '==' operator too
    aNumber == 12
expectPass

it "should make basic operations on two arrays"
try
    Array Letters
    Array Letters2

    Letters.Add "Hello Bobby"
    Letters.Add "Hello Maria"
    Letters.Contains "Hello Bobby"
    Letters.Contains "Hello Maria"

    Letters2.Add "Hello Midori,
                  Best regards!"

    lettersRef=$(Letters)
    Letters2.Merge "${!lettersRef}"

    Letters2.Contains "Hello Bobby"
expectPass

it 'should make a boolean and assign false to it'
try
    Boolean aBool = false
    ! $(aBool)
expectPass

it 'should make a boolean and assign true to it'
try
    Boolean aBool = true
    $(aBool)
expectPass

it "is playing der saxomophone! $(UI.Powerline.Saxophone)"
    try
    sleep 0
expectPass

Test.DisplaySummary

Test.NewGroup "Exceptions"

it 'should manually throw and catch an exception'
try
    throw 'I like to fail!'
expectFail

it 'should throw and catch an unknown reference exception'
try
    unknown_reference # This will throw
expectFail

it 'should nest try-and-catch'
try {
    try {
        try {
            throw "Inner-Most"
            echo Not executed
        } catch {
            cought
            throw "Outer"
            echo Not executed
        }
    } catch {
        cought
    }
}
expectOutputPass

Test.DisplaySummary


