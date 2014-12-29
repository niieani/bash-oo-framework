#!/bin/bash

## BOOTSTRAP ##
__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/oo-core.sh"

## MAIN ##
oo:import lib/types
oo:import tests/types/examples
oo:import tests/core-test
