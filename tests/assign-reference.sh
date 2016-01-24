#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

#Log.Debug.SetLevel 3

import lib/types/base
import lib/types/ui
import lib/types/util/test

reftest() {
    [reference] table
    [reference] retval

    echo ${table[test]}
    table[ok]=added

    retval="boom"
}

declare -A assoc
assoc[test]="hi"

declare outerKlops
reftest assoc outerKlops

echo ${assoc[ok]}

## dynamic references

passingTest() {
	[string] hello
	[string] makownik
	[string] third
	
	echo Inside Test Func
	echo $hello + $makownik + $third

	declare -n
}

second="works!"
someArray=(a b c)

passingTest first $ref:second $ref:someArray[1]



#declare -n refToLocal="klops"
#echo ${refToLocal[tat]}
