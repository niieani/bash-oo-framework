#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-bootstrap.sh"

import lib/types/base
import lib/types/ui
import lib/types/util/test

set -h
#set -k
alias kapusta="echo I alias"
kapusta

ignore() { printf ""; }

#trap="local argument+=( \\\"\\\$_\\\" ); printf \"[\\\$argument]\"; trapCount+=1; echo trap [\\\$trapCount / \\\$((\\\$trapCount / 6 + 1))] last "
trap="argument+=( \\\"\\\$_\\\" ); trapCount+=1; echo trap [\\\$trapCount]; ignore last"
alias :="declare -a argument; declare -i trapCount=0; trap \"$trap\" DEBUG; eval"
#alias :="declare -i trapCount=0; declare -i paramCount; paramCount+=1; trap \"$trap\" DEBUG; eval"

checkFlow()
{
    # FLOW: DEBUG last name1 argument trapCount=0 DEBUG last name2 argument trapCount=0 DEBUG last name3 test
    # if flow is disrupted
    # [ DEBUG last $NAME argument trapCount=0 ]
    # 4th element should be argument
    # if it's not, we can return true
    # and then we disrupt

    # 1st. measure distance between DEBUG and DEBUG, if it doesn't repeat, return FALSE
    # 2nd.
}

de() {
#    set -h
#    set -k
    #alias @kapusta2="local"
#    alias kapusta23="echo I alias2"
#    kapusta23 after
##    echo $after
#
#    @ @one nazwa
#    # paramCount = 1
#
#    # trapCount = 1
#    @ [string] cos
#    # paramCount = 2
#
#    # trapCount = 2
#    normal
#    # trapCount = 3 -- different, stop trap and release
#    blabla

#    [string] test
#    [string] test2
#    [string] test3
    : echo name1
    : echo name2
    : echo name3

    echo test
    echo ${argument[@]}
}
de test1 test2 test3

# aliases only work when defined before a function was entered
# the only exception is $() shell, but locals die inside of it

#de() {
#    trap "echo $@" DEBUG
#    alias @kapusta2="local"
#    alias @kapusta23="echo I alias2"
#    eval @kapusta2 after=test
#    echo $after
#}
#de ata
#
#@NumberAssign(){
#    local varName="$1"
#    shift
#    local allParams="$@"
#    $varName="${allParams[0]}"
#    (count++)
#}
#count=0
#assign $1 nazwaZmiennej
#
#alias @="assign ${!count} "
#alias @="local _value=$1; shift; assign ${!count} "
#
#@(){
#    type=$1
#    name=$2
#
#}
#
#something(){
#    @ Number X
#    @ String paplon
#    @ mixed something
#
#}
#kapusta2 outside
#
#fe(){
#    kapusta2 inside another
#}
#fe

#Log.Debug.SetLevel:4

#Test.Start 'should print a colorful message'