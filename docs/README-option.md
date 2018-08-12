# Options Handling

Set of scripts to handle script options/parameters.

## Manage Options: text mode

To create an option menu:

* Import the option script:
 ```python
  import util/option
  ```

* Create an option menu and an option menu wrapper:
 ```python
  Options optionMenu
  OptionsWrapper optionMenuWrapper
  ```
  
* Create a default values array using index with the format:
[optionName,optionValue,optionLetter,optionFlag,optionRequired]
 ```python
  declare -A DEFAULTS
  DEFAULTS[one,1,a,false,true]=''
  DEFAULTS[two,2,b,false,false]=''
  DEFAULTS[verbose,false,v,true,false]=''
  ```
  
* Set the default values:
```python
  Options optionMenu=$($var:optionMenuWrapper SetDefaults optionMenu DEFAULTS)
  ```
  
 * Now you can use Option functions:
```python
  declare -A PARAMETERS=$($var:optionMenuSample ToArray)
  echo "${PARAMETERS[one]}"
  echo "${PARAMETERS[two]}"
  ```
* You can also add options manually:
 ```python
  Option optionA
  $var:optionA name = 'one'
  $var:optionA value = 1
  $var:optionA letter = 'a'
  $var:optionA flag = false
  $var:optionA required = true
  $var:optionMenu Set optionA
  ```
## Manage Options: graphical user interface

* Create the defaults as above and then call yad function:
 ```python
  Options optionMenu=$($var:optionMenuWrapper GetOptionsGUI optionMenu)
  ```
## Limitations

* Currently only supports one word option values.

