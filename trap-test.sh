#!/usr/bin/env bash

source 'lib.trap.sh'

dupa2(){
#    rm kapusniak
#    illegal here
    backtrace 1
}

dupa(){
    echo test
    dupa2
}

echo "doing something wrong now .."
dupa

exit 0
