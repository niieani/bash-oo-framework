#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../../lib/oo-bootstrap.sh"

## MAIN ##

import lib/type-core
import lib/types/base
import lib/types/ui

import tests/exception-demo/demo
prepareTheCastle "Burning Candles"
