#!/usr/bin/env bash

## BOOTSTRAP ##
__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/boilerplate.sh"

## MAIN ##

oo:import lib/try-catch
oo:import lib/kernel
oo:import lib/types/base
oo:debug:enable 2
oo:import lib/types/ui

