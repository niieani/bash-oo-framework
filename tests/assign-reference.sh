#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-framework.sh"

#Log.Debug.SetLevel 3

import lib/types/base
import lib/types/ui
import lib/types/util/test

reftest() {
    @reference table
    @reference retval

    echo ${table[test]}
    table[ok]=added

    retval="boom"
}

declare -A assoc
assoc[test]="hi"

declare outerKlops
reftest assoc outerKlops


echo ${assoc[ok]}

#declare -n refToLocal="klops"
#echo ${refToLocal[tat]}
