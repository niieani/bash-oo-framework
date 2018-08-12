import util/class util/namedParameters
import util/tryCatch

class:Option() {

  public string name
  public string value
  public string letter
  public string flag
  public string required

  Option.__getter__() {
    serializedOption="{\"name\":\"$(this name)\",\"value\":\"$(this value)\",\"letter\":\"$(this letter)\",\"flag\":\"$(this flag)\",\"required\":\"$(this required)\"}"
    @return:value $serializedOption
  }

}

Type::Initialize Option

class:Options() {

  public map optionsMap
 
  # To check if GUI succeeded on getting options.
  public string yadSuccess

  Options.ToArray() {
    map toSetOptionsArray
    string indexList=$(this optionsMap)
    indexList=$($var:indexList sanitizeJSON)
    string serializedOption
   
    for serializedOption in $indexList; do
      serializedOption=$($var:serializedOption sanitizeSingleJSON)
      optionName=$(Options::GetSerializedAttribute "$serializedOption" 'name')
      optionValue=$(Options::GetSerializedAttribute "$serializedOption" 'value')
      toSetOptionsArray[$optionName]=$optionValue
    done

    @return toSetOptionsArray
  }

  Options.__getter__() {
    string indexList=$(this optionsMap)
    @return:value "$($var:indexList sanitizeJSON)"
  }

  Options.Set() {
    [reference] toSet
    this optionsMap set "$($var:toSet name)" "$($var:toSet)"
  }

  Options.Delete () {
    [reference] toDelete
    this optionsMap delete "$($var:toDelete name)"
  }

  Options::GetSerializedAttribute() {
    [string] serializedOption
    [string] attributeName
    attributeValue=''
    regex="$attributeName\":\"([[:alnum:]]+)"
    [[ $serializedOption =~ $regex ]] && attributeValue="${BASH_REMATCH[1]}"
    echo "$attributeValue"
  }

  Options::Unserialize() {
    [string] serializedOption
    [reference] toReturn
    serializedOption=$($var:serializedOption sanitizeSingleJSON)
    $var:toReturn name = $(Options::GetSerializedAttribute "$serializedOption" 'name')
    $var:toReturn value = $(Options::GetSerializedAttribute "$serializedOption" 'value')
    $var:toReturn letter = $(Options::GetSerializedAttribute "$serializedOption" 'letter')
    $var:toReturn flag = $(Options::GetSerializedAttribute "$serializedOption" 'flag')
    $var:toReturn required = $(Options::GetSerializedAttribute "$serializedOption" 'required')
  }

  Options.Search() {
    [string] attributeName
    [string] textToSearch
    Option optionFound
    string serializedOption
    string indexList=$(this optionsMap)
    indexList=$($var:indexList sanitizeJSON)
    itemFound=false

    for serializedOption in $indexList; do
      serializedOption=$($var:serializedOption sanitizeSingleJSON)
      attributeValue=$(Options::GetSerializedAttribute "$serializedOption" "$attributeName")
      if [[ "$attributeValue" == "$textToSearch" ]]; then
        itemFound=true
        break
      fi
    done

    [[ "$itemFound" == false ]] && return 1
    Options::Unserialize "$serializedOption" $ref:optionFound
    @return optionFound
  }

  Options.GetOptionsString() {
    optionsString=''
    optionLetter=''
    optionFlag=false
    string serializedOption
    string indexList=$(this optionsMap)
    indexList=$($var:indexList sanitizeJSON)

    for serializedOption in $indexList; do
      serializedOption=$($var:serializedOption sanitizeSingleJSON)
      optionLetter=$(Options::GetSerializedAttribute "$serializedOption" 'letter')
      optionFlag=$(Options::GetSerializedAttribute "$serializedOption" 'flag')

      optionsString+=$optionLetter
      if [[ "$optionFlag" == true ]]; then
        optionsString+=','
      else
        optionsString+=':'
      fi
    done
    @return:value $optionsString
  }

}

Type::Initialize Options

class:OptionsWrapper() {

  OptionsWrapper.GetOptionsGUI() {
    [reference] toSaveOptionsGUI
    string serializedOption
    Option guiOption
    string indexList="$($var:toSaveOptionsGUI optionsMap)"
    indexList=$($var:indexList sanitizeJSON)
    optionName=''
    optionValue=''
    optionFlag=false
    $var:toSaveOptionsGUI yadSuccess = true

    yadInstalled=$(which 'yad')
    if [[ -z "$yadInstalled" ]]; then
      $var:toSaveOptionsGUI yadSuccess = false
    fi

    # Generate yad form.
    yadString='yad --form --title="Set options" '
    yadOptionsString=''
    yadFlagsString=''
    yadOption=''
    yadLabels=''

    # Save index names to manipulate options array later.
    optionsNamesList=''
    flagsNamesList=''

    for serializedOption in $indexList; do
      serializedOption=$($var:serializedOption sanitizeSingleJSON)
      optionName=$(Options::GetSerializedAttribute "$serializedOption" 'name')
      optionValue=$(Options::GetSerializedAttribute "$serializedOption" 'value')
      optionFlag=$(Options::GetSerializedAttribute "$serializedOption" 'flag')

      # When executing yad with eval, the text with the form: --field="${option[value]}"
      # does not get well parsed, to prevent that, add to the yad string the keywords 'name:' and 'value'
      # and then replace them with the actual values.
      yadOption='--field="name": value '
      yadOption=${yadOption/name/$optionName}

      # Set the type to checkbox.
      if [[ "$optionFlag" == true ]]; then
        yadOption=${yadOption/ value/CHK $optionValue}
        yadFlagsString+=$yadOption
        flagsNamesList+="$optionName "
   
      else
        yadOption=${yadOption/value/$optionValue}
        yadOptionsString+=$yadOption
        optionsNamesList+="$optionName "
      fi
    done

    # Show menu.
    yadString+=${yadOptionsString}${yadFlagsString}
    yadInput=$(eval $yadString)

    string optionsLabelsList="${optionsNamesList}${flagsNamesList}"

    optionsLabelsList=$($var:optionsLabelsList trim)
    yadLabels=($optionsLabelsList)

    # Read the values and store them on the options map.
    index=0
    IFS='|' read -ra input <<< "$yadInput"
    for value in "${input[@]}"; do
      optionName="${yadLabels[$index]}"
      optionValue="$value"

      # Search option on defaults.
      Option guiOption=$($var:toSaveOptionsGUI Search 'name' "$optionName")

      # If required value must be provided.
      optionRequired=$($var:guiOption required)
      if [[ "$optionRequired" == true ]]; then
        try {
          ! [[ -z "$optionValue" ]]
        } catch {
          echo "The option $optionName is required, process aborted." | yad --text-info --width=400 --height=200
          $var:toSaveOptionsGUI yadSuccess = false
        }
      fi

      # Set new value.
      $var:guiOption value = "$optionValue"
      $var:toSaveOptionsGUI Set guiOption
      ((index++))
    done
    @return toSaveOptionsGUI
  }

  OptionsWrapper.SetDefaults() {
    [reference] toSaveDefaultOptions
    [reference] defaultOptions
    string serializedOption
    string indexList="$($var:defaultOptions)"
    indexList=$($var:indexList unJsonfy)
    Option toDefault

    for serializedOption in $indexList; do
      # Replace comma with space.
      serializedOption=${serializedOption//,/ }
      serializedArray=($serializedOption)
      $var:toDefault name = "${serializedArray[0]}"
      $var:toDefault value = "${serializedArray[1]}"
      $var:toDefault letter = "${serializedArray[2]}"
      $var:toDefault flag = "${serializedArray[3]}"
      $var:toDefault required = "${serializedArray[4]}"
      $var:toSaveDefaultOptions Set toDefault
    done 
    @return toSaveDefaultOptions
  }

  OptionsWrapper.ParseArguments() {
    [reference] toSaveParsedOptions
    optionsString=$($var:toSaveParsedOptions GetOptionsString)
    string optionValue=''
    optionName=''
    optionFlag=false

    shift
    while getopts $optionsString opt; do
      try {
        ! [[ "$opt" == "?" ]]
      } catch {
        echo "Ilegal option '$opt'."
        return 1
      }

      Option parsedOption=$($var:toSaveParsedOptions Search 'letter' "$opt")
      optionFlag=$($var:parsedOption flag)
      
      optionValue=true
      [[ "$optionFlag" == false ]] && optionValue="${OPTARG}"

      optionValue=$($var:optionValue trim)
      $var:parsedOption value = "$optionValue"
      $var:toSaveParsedOptions Set parsedOption

    done
    @return toSaveParsedOptions
  }
}

Type::Initialize OptionsWrapper

# Sanitize to a maximun of two levels only.
string.sanitizeJSON() {
  @resolve:this
  local toSanitize="$this"
  local sanitizedJSONString=''

  # Remove \".
  toSanitize="${toSanitize//\\\"/}"
  # Remove ".
  toSanitize="${toSanitize//\"/}"
  # Remove [.
  toSanitize="${toSanitize//\[/}"
  # Replace ]= with :.
  toSanitize="${toSanitize//\]=/:}"
  # Replace ( with {.
  toSanitize="${toSanitize//\(/{}"
  # Replace ) with }.
  toSanitize="${toSanitize//\)/}}"
  # Replace space} with }.
  toSanitize="${toSanitize//\ \}/}}"
  # Replace space with space,.
  toSanitize="${toSanitize// / ,}"
  # Trim.
  toSanitize=$(var: toSanitize trim)

  # Sanitize object by object.
  for jsonItem in $toSanitize; do
    jsonItem=$(var: jsonItem sanitizeSingleJSON)
    sanitizedJSONString+=$jsonItem
    sanitizedJSONString+=' ,'
  done
  sanitizedJSONString="${sanitizedJSONString::-2}"

  # Verify if this is a single json option.
  # If not, put {}.
  openingBracketsCount=$(echo $sanitizedJSONString | grep -o '{' | wc -l)
  [[ $openingBracketsCount -gt 1 ]] && sanitizedJSONString="{${sanitizedJSONString}}"

  @return sanitizedJSONString
}

string.sanitizeSingleJSON() {
  @resolve:this
  local toSanitizeSingle="$this"
  regex='.*(\{.*\})'

  # Verify this is a single JSON option.
  openingBracketsCount=$(echo $toSanitizeSingle | grep -o '{' | wc -l)
  [[ $openingBracketsCount -gt 2 ]] && @return toSanitizeSingle

  # Remove \".
  toSanitizeSingle="${toSanitizeSingle//\\\"/}"
  # Remove ".
  toSanitizeSingle="${toSanitizeSingle//\"/}"

  # Replace double {{ }} with single { }.
  toSanitizeSingle="${toSanitizeSingle//\{\{/\{}"
  toSanitizeSingle="${toSanitizeSingle//\}\}/\}}"
  
  [[ $toSanitizeSingle =~ $regex ]] && toSanitizeSingle="${BASH_REMATCH[1]}"

  # Remove all { }.
  toSanitizeSingle="${toSanitizeSingle//\{/}"
  toSanitizeSingle="${toSanitizeSingle//\}/}"

  # Put " back.
  toSanitizeSingle="${toSanitizeSingle//:/\":\"}"
  toSanitizeSingle="${toSanitizeSingle//,/\",\"}"
  toSanitizeSingle="\"${toSanitizeSingle}\""

  # Put { } back.
  toSanitizeSingle="{${toSanitizeSingle}}"

  @return toSanitizeSingle
}

string.unJsonfy() {
  @resolve:this
  local toUnJsonfy="$this"
  # Remove (.
  toUnJsonfy=${toUnJsonfy//\(/}
  # Remove ).
  toUnJsonfy=${toUnJsonfy//\)/}
  # Remove ].
  toUnJsonfy=${toUnJsonfy//\]/}
  # Remove {.
  toUnJsonfy=${toUnJsonfy//\}/}
  # Remove }.
  toUnJsonfy=${toUnJsonfy//\{/}
  # Remove =.
  toUnJsonfy=${toUnJsonfy//\=/}
  # Remove ".
  toUnJsonfy="${toUnJsonfy//\"/}"

  # Replace [ with space,.
  toUnJsonfy=${toUnJsonfy//\[/ ,}
  toUnJsonfy=$(var: toUnJsonfy trim)
  [[ "${toUnJsonfy:0:1}" == ',' ]] && toUnJsonfy="${toUnJsonfy:1}"
  @return toUnJsonfy
}

string.trim() {
  @resolve:this
  local toTrim="$this"
  # Remove leading whitespace.
  toTrim="${toTrim#"${toTrim%%[![:space:]]*}"}"
  # Remove trailing whitespace.
  toTrim="${toTrim%"${var##*[![:space:]]}"}"   
  toTrim=$(echo -n "$toTrim")
  @return toTrim
}

