#!/usr/bin/env bash
set -o pipefail

shopt -s expand_aliases

Log.Write() {
    echo "${@}"
}

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/system/02_named_parameters.sh"

testPassingParams() {
    [string] hello
    [string] two

    true normal code
    true normal code2
    true normal code3

    echo $hello $two

    # l=4 [string[]] anArrayWithFourElements
    # l=2 [string[]] anotherArrayWithTwo
    # [string] anotherSingle
    # [reference] table
    # [...rest] anArrayOfVariedSize

    # test "$hello" = "$1"
    # #
    # test "${anArrayWithFourElements[0]}" = "$2"
    # test "${anArrayWithFourElements[1]}" = "$3"
    # test "${anArrayWithFourElements[2]}" = "$4"
    # test "${anArrayWithFourElements[3]}" = "$5"
    # #
    # test "${anotherArrayWithTwo[0]}" = "$6"
    # test "${anotherArrayWithTwo[1]}" = "$7"
    # #
    # test "$anotherSingle" = "$8"
    # #
    # test "${table[test]}" = "works"
    # table[inside]="adding a new value"
    # #
    # test "${anArrayOfVariedSize[*]}" = "${*:10}"
}

fourElements=( a1 a2 "a3 with spaces" a4 )
twoElements=( b1 b2 )
declare -A assocArray
assocArray[test]="works"

testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

test "${assocArray[inside]}" = "adding a new value"