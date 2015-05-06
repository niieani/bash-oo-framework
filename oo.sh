#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-framework.sh"

## MAIN ##

import lib/type-core
import lib/types/base
import lib/types/ui

# echo hello

#Log.Debug.SetLevel 1


  String kapusta = "kapusniaczek"
  kapusta
  
  # echo source ${BASH_SOURCE[0]} $0
  kapusta ++

try
  #String kapusta
  String kapusta = "kapusniaczek"
  kapusta
  
  # echo source ${BASH_SOURCE[0]} $0
  kapusta ++
catch {
  #echo errorALL ${__EXCEPTION__[*]}
  Exception.PrintException "${__EXCEPTION__[@]}"
  #echo errorEXP ${__BACKTRACE_COMMAND__[0]}
  #echo errorSRC ${__BACKTRACE_SOURCE__[0]}
  #echo errorLNO ${__BACKTRACE_LINE__[0]}
  #throw
}
# try
#   String kapusta = "kapusniaczek"
#   kapusta
# catch
#   echo error

# try
#   echo mizerota
#   lambda=123
#   String kapusta = "kapusniaczek"
#   kapusta
#   #=> $(kapusta) result unreachable
#   # false
# catch {
#   echo caught
#   echo $__EXCEPTION_SOURCE__
#   #=> ${__EXCEPTION_SOURCE__} result unreachable
# }
