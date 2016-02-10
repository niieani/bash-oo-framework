#!/bin/bash

# Log Call Stack
LSLOGSTACK () {
  local i=0
  local FRAMES=${#BASH_LINENO[@]}
  # FRAMES-2 skips main, the last one in arrays
  for ((i=FRAMES-2; i>=0; i--)); do
    echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
    # Grab the source code of the line
    sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i+1]}"
  done
}

deeper(){
    echo deeper
    echo name: $name
    name=changed
#    echo this: ${FUNCNAME[0]}
#    echo parent: ${FUNCNAME[1]}
#    echo source: ${BASH_SOURCE[1]}
}
inside(){
#    echo params "$@"
#    echo
#    echo surface
#    caller 0
#    ps -ocommand= -p $PPID | awk "{print $1}" | awk -F/ "{print $NF}"
#    ps -ocommand=
    local name=$1
    deeper
    echo $name
}

inside "$@"
