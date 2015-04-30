#!/usr/bin/env bash

source oo.sh
oo:import tests/types/test

compgen -A function UICursor
#UICursor testing
#testing.Capture

it 'should print a colorful message'
try
    echo $(UI.Color.Green)Hello!$(UI.Color.Default)
finish

it 'should fail'
try
    false
finish

UI.Powerline.Saxophone
UI.Powerline.ThumbsUp

#Number YoMamaNumber = 150


#oo:import tests/types/examples
#oo:import tests/core-test
