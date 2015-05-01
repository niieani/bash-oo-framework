#!/usr/bin/env bash

__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/boilerplate.sh"

import lib/types/system
import lib/types/base
import lib/types/ui

Log.Debug:Enable 4


import test-logging