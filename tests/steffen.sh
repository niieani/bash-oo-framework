#!/usr/bin/env bash

## BOOTSTRAP ##
NO_UNICODE=true source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

namespace MyApp
Log::AddOutput MyApp CUSTOM

subject=WARN Log "I am a warning"
subject=STEFFEN Log "I am a Steffen :-)"