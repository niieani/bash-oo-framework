#!/usr/bin/env bash

source "$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )/../lib/oo-framework.sh"

#Log.Debug.SetLevel 3

import lib/types/base
import lib/types/ui
import lib/types/util/test

reftest() {
    @reference table

    echo ${table[test]}
    table[ok]=added
}

declare -A assoc
assoc[test]="hi"

reftest assoc
echo ${assoc[ok]}
