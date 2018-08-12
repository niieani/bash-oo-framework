# Options Handling

Set of scripts to handle script options/parameters.

## Manage Options: text mode

To create an option menu:

* Import the option script:
  
  import util/option

* Create an option menu and an option menu wrapper.

  Options optionMenuYad
  OptionsWrapper optionMenuWrapperYad

* Create a default values array using index with the format:

    [optionName,optionValue,optionLetter,optionFlag,optionRequired]

  Where each index part is:

    * optionName: name of the option. Example: username.

    * optionValue: the value to set as default. Example: 777.

    * optionLetter: letter used on text mode to especify an argument. Example: a.

    * optionFlag: true or false value indicating if this option is a flag. Flag options can only take 
      true or false values, are marked as 'without argument' on the string passed to getopts 
      and are displayed as checkboxes on the GUI.

    * optionRequired: true or false value indicating if this option is required. This attribute is
      used on the GUI to verify if the user left a required option empty.

  declare -A DEFAULTS
  DEFAULTS[one,1,a,false,true]=''
  DEFAULTS[two,2,b,false,false]=''
  DEFAULTS[verbose,false,v,true,false]=''

* Set the default values:

  Options optionMenuSample=$($var:optionMenuWrapperSample SetDefaults optionMenuSample DEFAULTS_SAMPLE)

* Now you can use Option functions:

  declare -A PARAMETERS=$($var:optionMenuSample ToArray)
  echo "${PARAMETERS[one]}"
  echo "${PARAMETERS[two]}"

* You can also add options manually:

  Option optionA
  $var:optionA name = 'one'
  $var:optionA value = 1
  $var:optionA letter = 'a'
  $var:optionA flag = false
  $var:optionA required = true
  
  $var:optionMenu Set optionA

## Manage Options: graphical user interface mode

* Create the defaults as above and then call yad function:

  Options optionMenu=$($var:optionMenuWrapper GetOptionsGUI optionMenu)

## Limitations

* Currently only supports one word option values (fixing real soon).
