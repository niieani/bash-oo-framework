#!/bin/bash
#
# Options object test.

source "$( cd "${BASH_SOURCE[0]%/*}" && cd .. && pwd )/lib/oo-bootstrap.sh"

import util/test UI/Color
import util/option

Option optionA
$var:optionA name = 'one'
$var:optionA value = 1
$var:optionA letter = 'a'
$var:optionA flag = false
$var:optionA required = true

Option optionB
$var:optionB name = 'two'
$var:optionB value = 2
$var:optionB letter = 'b'
$var:optionB flag = false
$var:optionB required = false

Option optionVerbose
$var:optionVerbose name = 'verbose'
$var:optionVerbose value = true
$var:optionVerbose letter = 'v'
$var:optionVerbose flag = true
$var:optionVerbose required = false

OptionsWrapper optionMenuWrapper
Options optionMenu
Option optionItem

it 'should manually add options.'
try
  $var:optionMenu Set optionA
  $var:optionMenu Set optionB
  $var:optionMenu Set optionVerbose
  serializedOptions=$($var:optionMenu)
  [[ "$serializedOptions" = *'verbose'* ]]
expectPass

it 'should add options from array.'
  declare -A DEFAULTS
  DEFAULTS[one,1,a,false,true]=''
  DEFAULTS[two,2,b,false,false]=''
  DEFAULTS[three,3,c,false,false]=''
  DEFAULTS[verbose,true,v,true,false]=''
  Options optionMenu=$($var:optionMenuWrapper SetDefaults optionMenu DEFAULTS)
  serializedOptions=$($var:optionMenu)
  [[ "$serializedOptions" = *'three'* ]]
try

expectPass

it 'should delete option.'
try
  $var:optionMenu Delete optionB
  serializedOptions=$($var:optionMenu)
  ! [[ "$serializedOptions" = *'two'* ]]
expectPass

it 'should get serialized attribute.'
try
  optionName=$(Options::GetSerializedAttribute "$($var:optionA)" 'name')
  test "$optionName" = 'one'
expectPass

it 'should unserialize option.'
try
  Options::Unserialize "$($var:optionA)" $ref:optionItem
  optionName=$($var:optionItem name)
  test "$optionName" = 'one'
expectPass

it 'should find option.'
try
  $var:optionMenu Set optionA
  $var:optionMenu Set optionVerbose
  Option optionItem=$($var:optionMenu Search 'name' 'one')
  optionName=$($var:optionItem name)
  test "$optionName" = 'one'
expectPass

it 'should get options string.'
try
  optionsString=$($var:optionMenu GetOptionsString)
  test "$optionsString" = 'b:c:v,a:'
expectPass

it 'should parse arguments.'
try
  # Simulate call the script like: ./test-option.sh -a 777
  set -- "${@:1:2}" '-a 777'
  Options optionMenu=$($var:optionMenuWrapper ParseArguments optionMenu "$@")
  serializedOptions=$($var:optionMenu)
  [[ "$serializedOptions" = *'777'* ]]
expectPass

it 'should copy values from Object to associative array.'
try
  Options optionMenu=$($var:optionMenuWrapper SetDefaults optionMenu DEFAULTS)
  declare -A PARAMETERS=$($var:optionMenu ToArray)
  [[ "${PARAMETERS[two]}" = '2' ]]
expectPass

