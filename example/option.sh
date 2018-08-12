#!/bin/bash
#
# Example Option, Options and OptionsWrapper objects use.

source "$( cd "${BASH_SOURCE[0]%/*}" && cd .. && pwd )/lib/oo-bootstrap.sh"

import util/option

OptionsWrapper optionMenuWrapper
Options optionMenu

echo 'Set default values manually.'

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
$var:optionVerbose value = false
$var:optionVerbose letter = 'v'
$var:optionVerbose flag = true
$var:optionVerbose required = false

# Add options.
$var:optionMenu Set optionA
$var:optionMenu Set optionB
$var:optionMenu Set optionVerbose

$var:optionMenu
echo '----------------'

echo 'Set default values from array.'
# Set defaults index as: [name,value,letter,flag,required]
declare -A DEFAULTS
DEFAULTS[one,1,a,false,true]=''
DEFAULTS[two,2,b,false,false]=''
DEFAULTS[three,3,c,false,false]=''
DEFAULTS[verbose,false,v,true,false]=''

Options optionMenu=$($var:optionMenuWrapper SetDefaults optionMenu DEFAULTS)
$var:optionMenu
echo '----------------'

echo 'Serialize all options.'
$var:optionMenu
echo '----------------'

echo 'Delete option.'
$var:optionMenu Delete optionB
$var:optionMenu
echo '----------------'

echo 'Serialize option.'
serializedOption=$($var:optionA)
echo "$serializedOption"
echo '----------------'

echo 'Get attributes from serialized string.'
Options::GetSerializedAttribute "$serializedOption" 'name'
Options::GetSerializedAttribute "$serializedOption" 'value'
echo '----------------'

echo 'Unserialize option.'
Option optionC
Options::Unserialize "$serializedOption" $ref:optionC
$var:optionC name
$var:optionC value
echo '----------------'

echo 'Search option by name.'
Option optionC=$($var:optionMenu Search 'name' 'verbose')
$var:optionC
echo '----------------'

echo 'Search option by letter.'
Option optionC=$($var:optionMenu Search 'letter' 'a')
$var:optionC
echo '----------------'

echo 'Get options string.'
$var:optionMenu GetOptionsString
echo '----------------'

# Simulate call the script like: ./example-option.sh -a 777
echo 'Parse arguments -a 777'
set -- "${@:1:2}" '-a 777'

Options optionMenu=$($var:optionMenuWrapper ParseArguments optionMenu "$@")
$var:optionMenu
echo '----------------'

echo 'Copy values from Object to associative array.'
declare -A PARAMETERS=$($var:optionMenu ToArray)
echo "${PARAMETERS[@]}"
echo '----------------'

echo 'Basic use: read defaults from array, write results to associative array.'

echo '  DEFAULTS[one,1,a,false,true] > Options Object'
echo '  DEFAULTS[two,2,b,false,false] > Options Object'

echo '  Option Object > PARAMETERS[one]="1"'
echo '  Option Object > PARAMETERS[two]="2"'

Options optionMenuSample
OptionsWrapper optionMenuWrapperSample

# Name,value,letter,flag,required.
declare -A DEFAULTS_SAMPLE
DEFAULTS_SAMPLE[one,1,a,false,true]=''
DEFAULTS_SAMPLE[two,2,b,false,false]=''
Options optionMenuSample=$($var:optionMenuWrapperSample SetDefaults optionMenuSample DEFAULTS_SAMPLE)

declare -A PARAMETERS_SAMPLE=$($var:optionMenuSample ToArray)

for index in "${!PARAMETERS_SAMPLE[@]}"; do
  echo "$index : ${PARAMETERS_SAMPLE[$index]}"
done

echo "${PARAMETERS_SAMPLE[one]}"
echo "${PARAMETERS_SAMPLE[two]}"
echo '----------------'

echo 'Graphical User Interface with yad.'
Options optionMenuYad
OptionsWrapper optionMenuWrapperYad

# Name,value,letter,flag,required.
declare -A DEFAULTS_YAD
DEFAULTS_YAD[one,1,a,false,true]=''
DEFAULTS_YAD[two,2,b,false,false]=''
DEFAULTS_YAD[verbose,false,v,true,false]=''

Options optionMenuYad=$($var:optionMenuWrapperYad SetDefaults optionMenuYad DEFAULTS_YAD)
Options optionMenuYad=$($var:optionMenuWrapperYad GetOptionsGUI optionMenuYad)

if [[ "$($var:optionMenuYad yadSuccess)" == true ]]; then
  $var:optionMenuYad
else
  echo "An error happend with yad."
fi
echo '----------------'

exit 0

