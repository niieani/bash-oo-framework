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

  ################################################################
  # Creates an options menu array from defaults values array and
  # the arguments string $@.
  # Unlike OptionsWrapper.ParseArguments this function does not
  # uses objects, this with the purpose of improve performance.
  # Arguments:
  #   sourceDefaults: default values array, 
  #     it must have indexes with the format:
  #       name,value,letter,flag,required.
  #   destinyOptions: array where to store options.
  # Globals:
  #   $@: string arguments passed to this script.
  # Returns:
  #   The options menu in the destiny array name.
  ################################################################
  Options::FastParseArguments() {
    sourceDefaults=$1
    destinyOptions=$2
    optionsString=''
    optionName=''
    optionValue=''
    optionLetter=''
    optionFlag=false
    local -a 'valuesIndex=("${!'"$sourceDefaults"'[*]}")'

    # Set default values and create options string.
    for valueIndex in $valuesIndex; do
      attributesArray=($valueIndex)
      DEFAULT_IFS="$IFS"
      IFS=","
      attributeItemArray=($attributesArray)
      IFS="$DEFAULT_IFS"

      optionName="${attributeItemArray[0]}"
      optionValue="${attributeItemArray[1]}"
      optionLetter="${attributeItemArray[2]}"
      optionFlag="${attributeItemArray[3]}"
      optionsString+="$optionLetter"

      # If option is a flag then an argument is not required.
      if [[ "$optionFlag" == true ]]; then
        optionsString+=','
      else
        optionsString+=':'
      fi
      eval $destinyOptions[$optionName]="$(echo $optionValue)"
    done

    shift 2
    while getopts $optionsString opt; do
      try {
        ! [[ "$opt" == "?" ]]
      } catch {
        echo "Ilegal option '$opt'."
        return 1
      }

      for valueIndex in $valuesIndex; do
        letterRegex=',([[:alpha:]]{1}),'

        if [[ $valueIndex =~ $letterRegex ]]; then
          optionLetter="${BASH_REMATCH[1]}"
          if [[ "$optionLetter" == "$opt" ]]; then
            attributesArray=($valueIndex)
            DEFAULT_IFS="$IFS"
            IFS=","
            attributeItemArray=($attributesArray)
            optionName="${attributeItemArray[0]}"
            optionValue="${attributeItemArray[1]}"
            optionFlag="${attributeItemArray[3]}"
            optionsString+="$opt"
            IFS="$DEFAULT_IFS"

            # If option is a flag then value is always true (present).
            if [[ "$optionFlag" == true ]]; then
              optionValue=true
            else
              optionValue="${OPTARG}"
            fi
            
            # Overwrite default value.
            eval $destinyOptions[$optionName]="$(echo $optionValue)"
            # Option found.
            break
          fi
        fi
      done
    done
    return 0
  }

  ################################################################
  # Shows a GUI with yad to capture option values.
  # Unlike OptionsWrapper.GetOptionsGUI this function does not
  # uses objects, this with the purpose of improve performance.
  # Arguments:
  #   sourceDefaults: default values array, 
  #     it must have indexes with the format:
  #       name,value,letter,flag,required.
  #   destinyOptions: array where to store options.
  # Returns:
  #   The options menu in the destiny array name.
  ################################################################
  Options::FastGetOptionsGUI() {
    sourceDefaults=$1
    destinyOptions=$2
    local -a 'valuesIndex=("${!'"$sourceDefaults"'[*]}")'
    optionName=''
    optionValue=''
    optionFlag=false
    optionRequired=false

    yadInstalled=$(which 'yad')
    if [[ -z "$yadInstalled" ]]; then
      return 1
    fi

    # Yad form.
    yadString='yad --form --title="Set options" '
    yadOptionsString=''
    yadFlagsString=''
    yadOption=''
    yadLabels=''

    # Save index names to manipulate options array later.
    optionsNamesList=''
    flagsNamesList=''

    # Set defaults and create yad form string.
    for valueIndex in $valuesIndex; do
      attributesArray=($valueIndex)
      DEFAULT_IFS="$IFS"
      IFS=","
      attributeItemArray=($attributesArray)
      IFS="$DEFAULT_IFS"

      optionName="${attributeItemArray[0]}"
      optionValue="${attributeItemArray[1]}"
      optionFlag="${attributeItemArray[3]}"

      # Set default value.
      eval $destinyOptions[$optionName]="$(echo $optionValue)"

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
    DEFAULT_IFS="$IFS"
    IFS='|' read -ra input <<< "$yadInput"
    for optionValue in "${input[@]}"; do
      IFS="$DEFAULT_IFS"
      optionName="${yadLabels[$index]}"

      # Find option to check if is required.
      nameValueRegex="$optionName,.*,.*,.*,([[:alpha:]]+)"
      for valueIndex in $valuesIndex; do

        if [[ $valueIndex =~ $nameValueRegex ]]; then
          optionRequired="${BASH_REMATCH[1]}"   
          if [[ "$optionRequired" == true ]] && [[ -z "$optionValue" ]]; then
            echo "The option '$optionName' is required, process aborted." | yad --text-info --width=400 --height=200
            return 1
          fi
        fi
      done
  
      # Rewrite default.
      eval $destinyOptions[$optionName]="$(echo '$optionValue')"
      ((index++))
      IFS='|'
    done
    IFS="$DEFAULT_IFS"
    return 0
  }

}

Type::Initialize Options

class:OptionsWrapper() {

  OptionsWrapper.SetDefaults() {
    [reference] toSaveDefaultOptions
    [reference] defaultOptions
    string serializedOption
    string indexList="$($var:defaultOptions)"
    indexList=$($var:indexList unJsonfy)
    Option toDefault
    optionName=''
    optionValue=''
    optionLetter=''
    optionFlag=false
    optionRequired=false

    DEFAULT_IFS="$IFS"
    IFS='|'
    for attributeList in $indexList; do
      IFS=','
      attributesArray=($attributeList)

      IFS=$DEFAULT_IFS
      $var:toDefault name = "${attributesArray[0]}"
      $var:toDefault value = "${attributesArray[1]}"
      $var:toDefault letter = "${attributesArray[2]}"
      $var:toDefault flag = "${attributesArray[3]}"
      $var:toDefault required = "${attributesArray[4]}"
      $var:toSaveDefaultOptions Set toDefault
    done
    IFS="$DEFAULT_IFS"
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
    DEFAULT_IFS="$IFS"
    IFS='|' read -ra input <<< "$yadInput"
    for value in "${input[@]}"; do
      IFS="$DEFAULT_IFS"
      optionName="${yadLabels[$index]}"
      optionValue="$value"

      Option guiOption=$($var:toSaveOptionsGUI Search 'name' "$optionName")

      # If required value must be provided.
      optionRequired=$($var:guiOption required)
      if [[ "$optionRequired" == true ]]; then
        try {
          ! [[ -z "$optionValue" ]]
        } catch {
          echo "The option '$optionName' is required, process aborted." | yad --text-info --width=400 --height=200
          $var:toSaveOptionsGUI yadSuccess = false
        }
      fi
   
      $var:guiOption value = "$optionValue"

      $var:toSaveOptionsGUI Set guiOption
      ((index++))
      IFS='|'
    done
    IFS="$DEFAULT_IFS"
    @return toSaveOptionsGUI
  }
}

Type::Initialize OptionsWrapper

# Sanitize to a maximun of two levels only.
string.sanitizeJSON() {
  @resolve:this
  local toSanitize="$this"
  local sanitizedJSONString=''

  # Trim.
  toSanitize=$(var: toSanitize trim)

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
  # Replace }space with }.
  toSanitize="${toSanitize//\}/\}}"
  # Replace }space with }|.
  toSanitize="${toSanitize//\} /\}\|}"

  # Sanitize json object by object.
  DEFAULT_IFS="$IFS"
  IFS="|"
  for jsonItem in $toSanitize; do
    jsonItem=$(var: jsonItem sanitizeSingleJSON)
    sanitizedJSONString+=$jsonItem
    sanitizedJSONString+=' ,'
  done
  IFS="$DEFAULT_IFS"
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

  # Replace [ with |,
  # Here we use | to denote option separation.
  toUnJsonfy=${toUnJsonfy//\[/\|}

  # Replace space| with |.
  toUnJsonfy=${toUnJsonfy// \|/\|}

  # Replace |space with |.
  toUnJsonfy=${toUnJsonfy//\| /\|}

  toUnJsonfy=$(var: toUnJsonfy trim)

  # Delete first |.
  [[ "${toUnJsonfy:0:1}" == '|' ]] && toUnJsonfy="${toUnJsonfy:1}"
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

