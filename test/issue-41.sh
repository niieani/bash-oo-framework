#!/usr/bin/env bash
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import util/log util/exception util/tryCatch util/namedParameters util/class

Log::AddOutput oo/type DEBUG

function q(){
  # declare -p 1
  [array] var
  # # @get 1
  # # echo "${var[@]}"
  # # echo
  :
  declare -p var
  for i in a; do
    declare -p var
  done
}

declare -a array_var=(a b c)
q "$(var: array_var)"
# # q "$(var: array_var)"
# echo 'Done'
# echo 'Done'
# echo 'Done'

# function example {
#   trap "echo trapped: \"\$BASH_COMMAND\" \"\$@\";" DEBUG
#   # echo before

#   local VARIABLE=value

#   # echo after
#   # echo finito
# }

# # declare -ft example
# example external_argument
# echo the end
