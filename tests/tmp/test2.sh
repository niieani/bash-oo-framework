#!/bin/bash

declare -a template0=( "123" "456" )
declare -a template1=( "zxc" "edc" )

i=0

template_name="template$i[@]"
echo ${!template_name}

full=template$i

#i=2
#declare -a "template$i=( 414 515 )"

modifyheyho() {
    heyho=true
}

doit() {
    declare -ga "template$i+=( \"one\" \"\$@\" )"
    declare -p template$i

    local heyho
    modifyheyho
    echo $heyho
}

doit "$@"

echo should be nothing $heyho

declare -p template$i

#declare -a template2=( "414" "515" )

shopt -s expand_aliases

alias booboo='echo booboo'

makealias(){
    booboo
    eval "alias bambo='ls'"
}

makealias

bambo