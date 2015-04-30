#!/usr/bin/env bash

source oo.sh
oo:import tests/types/test

it 'should print a colorful message'
try
    sleep 1
    hexDump="0000000 1b 5b 30 3b 33 32 6d 48 65 6c 6c 6f 21 1b 5b 30"
    message=$(echo $(UI.Color.Green)Hello!$(UI.Color.Default) | hexdump | head -1)
    [[ "$hexDump" = "$message" ]]
finish

it 'should fail'
try
    sleep 1
    false
finish

it 'is playing on a saxomophone!'
try
    sleep 1
    UI.Powerline.Saxophone
    echo
finish

echo $(UI.Powerline.ThumbsUp) All tests completed succesfully.

#UI.Powerline.Saxophone

#Number YoMamaNumber = 150


#oo:import tests/types/examples
#oo:import tests/core-test
