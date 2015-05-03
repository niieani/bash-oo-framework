#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )/lib/oo-framework.sh"

## MAIN ##

#Log.Debug.SetLevel 2
import lib/try-catch
import lib/kernel
import lib/types/base
import lib/types/ui

#Log.Debug.SetLevel 2
