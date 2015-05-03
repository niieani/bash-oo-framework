#!/usr/bin/env bash

__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/boilerplate.sh"

#trap "previous_command=\$this_command; this_command=\$BASH_COMMAND" DEBUG
#trap "throw \$previous_command" ERR


#Log.Debug:Enable 3
import lib/types/base
import lib/types/ui

import lib/types/util/test

#rm lampka

trap "throw \$BASH_COMMAND" ERR
set -o errtrace  # trace ERR through 'time command' and other functions
#Test.NewGroup "Objects"
laom(){
#    rm maowerkowekro
#    rm pkpkpkp
#    kapusta
    throw THIS IS UNACCEPTABLE
}

laom
#throw Some-error