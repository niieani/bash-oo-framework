#!/usr/bin/env bash

__oo__path="${BASH_SOURCE[0]%/*}"
[ -f "$__oo__path" ] && __oo__path=$(dirname "$__oo__path")
source "${__oo__path}/lib/boilerplate.sh"

import lib/types/base
import lib/types/ui
import lib/types/util/test

echo before $__oo__insideTryCatch
try
    echo inside $__oo__insideTryCatch
    throw dupa
catch
    echo cought $__oo__insideTryCatch

echo after $__oo__insideTryCatch

try
    echo inside $__oo__insideTryCatch
    throw dupa
catch
    echo cought $__oo__insideTryCatch

echo after $__oo__insideTryCatch

try
    echo inside $__oo__insideTryCatch
    throw dupa
catch
    echo cought $__oo__insideTryCatch

echo after $__oo__insideTryCatch

throw dupa


#it 'should try-and-catch nested'
#try {
#    try {
#        try {
#            echo Trying...
#            throw "Works"
#            echo Not executed
#        } catch {
#            echo "$__EXCEPTION_SOURCE__: Inner Cought $__EXCEPTION__ at $__EXCEPTION_LINE__"
#            throw "Fallback"
#        }
#    } catch {
#        echo "$__EXCEPTION_SOURCE__: Outer Cought $__EXCEPTION__ at $__EXCEPTION_LINE__"
#    }
#}
#finishEchoed
#
##set -x
#it 'should make an instance of an Object'
#try
#    test a = a
#    #Object anObject
#    #test "$(anObject)" = "[Object] anObject"
#    Test.OK
#catch
#    echo "$__EXCEPTION_SOURCE__: Cought $__EXCEPTION__ at $__EXCEPTION_LINE__"
#    #Test.Errors = true
#    #Test.Fail
#
#it 'should throw'
#try
#    test a = b
#catch {
#    echo "$__EXCEPTION_SOURCE__: Cought $__EXCEPTION__ at $__EXCEPTION_LINE__"
#    Test.EchoedOK
#}
#Test.Errors = true
#Test.Fail


#try
#    echo trying...
#    echo
##    blablabla
#    throw "This Works YEAH"
#    echo Not executed
#catch
#    echo "$__EXCEPTION_SOURCE__: Cought $__EXCEPTION__ at $__EXCEPTION_LINE__"