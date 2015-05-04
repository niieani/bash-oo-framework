#!/usr/bin/env bash
source "$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )/../lib/oo-framework.sh"

#Log.Debug.SetLevel 3

import lib/types/base
import lib/types/ui
import lib/types/util/test


Test.NewGroup "Exceptions"
it 'should try to assign map the params locally'
try
    testPassingParams() {
        @var hello
        l=4 @array anArrayWithFourElements
        l=2 @array anotherArrayWithTwo
        @var anotherSingle
        @params anArrayOfVariedSize

        test "$hello" = "$1" && echo correct
        #
        test "${anArrayWithFourElements[0]}" = "$2" && echo correct
        test "${anArrayWithFourElements[1]}" = "$3" && echo correct
        test "${anArrayWithFourElements[2]}" = "$4" && echo correct
        # ...
        test "${anotherArrayWithTwo[0]}" = "$6" && echo correct
        test "${anotherArrayWithTwo[1]}" = "$7" && echo correct
        #
        test "$anotherSingle" = "$8" && echo correct
        #
        test "${anArrayOfVariedSize[*]}" = "${*:9}" && echo correct
    }

    fourElements=( a1 a2 a3 a4 )
    twoElements=( b1 b2 )

    testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" "and more... " "even more..."

finishEchoed

Test.DisplaySummary


Test.NewGroup "Objects"

it 'should print a colorful message'
try
    hexDump="0000000 1b 5b 30 3b 33 32 6d 48 65 6c 6c 6f 21 1b 5b 30"
    message=$(echo $(UI.Color.Green)Hello!$(UI.Color.Default) | hexdump | head -1)
    [[ "$hexDump" = "$message" ]]
finish

it 'should make an instance of an Object'
try
    Object anObject
    test "$(anObject)" = "[Object] anObject"
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
finish

it 'should make a boolean and assign false to it'
try
    Boolean aBool = false
    ! $(aBool)
finish

it 'should make a boolean and assign true to it'
try
    Boolean aBool = true
    $(aBool)
finish

it "is playing der saxomophone! $(UI.Powerline.Saxophone)"
    try
    sleep 0
finish

Test.DisplaySummary

Test.NewGroup "Exceptions"

alias cought="echo \"Caught Exception: $(UI.Color.Red)\$__EXCEPTION__$(UI.Color.Default) in \$__EXCEPTION_SOURCE__:\$__EXCEPTION_LINE__\""

it 'should manually throw and catch an exception'
try
    throw 'I like to fail!'
catch {
    cought
    Test.EchoedOK
}
test $? -eq 1 && Test.Errors = false

it 'should throw and catch an unknown reference exception'
try
    unknown_reference # This will throw
catch {
    cought
    Test.EchoedOK
}
test $? -eq 1 && Test.Errors = false

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
finishEchoed

Test.DisplaySummary


