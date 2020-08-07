#!/usr/bin/env bash
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/../lib/oo-bootstrap.sh"

import util/log

namespace test/verbose
VERBOSE=2

Log::AddOutput test/verbose DEBUG

Log "this log will be printed"
V=2 Log "this log will be displayed"

VERBOSE=1
V=2 Log "this log will not be displayed"
