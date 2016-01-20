Type::ExecuteMethod() {
  local type="$1"
  local variableName="$2"
  local method="$3"

  shift; shift; shift;

  thisReference=$variableName thisReferenceType="$type" $type.$method "$@"
}

# /**
#  * used inside Type::Handle() for getting out the return value and updating this
#  */
Type::RunCurrentStack() {
  DEBUG Log "will execute: $method (${params[@]})"

  if [[ ! -z "$returnValueDefinition" && "$affectTheInitialVariable" == 'false' ]]
  then
    local -$(Variable::GetDeclarationFlagFromType returnValueType)"__self=$returnValueDefinition"
    variableName=__self
  fi

  # Log "Will assign: result=$(__return_self_and_result=true Type::ExecuteMethod "$type" "$variableName" "$method" "${params[@]}")"
  local resultString=$(__return_self_and_result=true Type::ExecuteMethod "$type" "$variableName" "$method" "${params[@]}")

  ## TODO: some problem here sometimes
  DEBUG Log "Result string: $resultString"

  # echo everything before the first occurence of the separator
  local echoed="${resultString%%$__return_separator*}"

  # the result is everything after the first occurence of the separator
  resultString="${resultString#*$__return_separator}"

  if [[ -z "$resultString" ]]
  then
    ## TODO: debug these situations
    local -a result=( "$(@get $variableName)" "" "" )
  else
    # Log "wtf $resultString"
    local -a result=$resultString
    # eval "local -a result=$resultString"
  fi

  unset __self

  # declare -p result
  local assignResult="${result[0]}"

  DEBUG Log "Assign Result:"
  DEBUG Log "START $assignResult END"
  # declare -p assignResult

  local typeParam=$(Variable::GetDeclarationFlagFromType $type)

  # Log "Will eval: | $variableName=$assignResult |"

  if [[ "$typeParam" =~ [aA] ]]
  then
    # update the object
    eval "$variableName=$assignResult"
  else
    eval "$variableName=\"\$assignResult\""
  fi

  # update the result
  returnValueDefinition="${result[1]}"
  returnValueType="${result[2]}"

  if [[ "$assignResult" != "${returnValueDefinition}" ]]
  then
    affectTheInitialVariable=false
    type="$returnValueType" # $(Variable::GetPrimitiveTypeFromDeclarationFlag $returnValueType)
  fi

  printf "$echoed"

  ## cleanup vars:
  method=''
  params=()

  # TODO: this should work directly but doesn't
  # eval $variableName=\$assignResult
}

Type::Handle() {
  local variableName="$1"
  local type=$(Type::GetTypeOfVariable $variableName)
  local affectTheInitialVariable=true
  local -a propertyTree=("$1")

  if [[ "$type" == "undefined" ]]
  then
    e="No variable named: $variableName" throw
    return
  fi

  shift

  local returnValueDefinition
  local returnValueType

  local multiExpression=false

  if [[ "$1" == ':' ]]
  then
    multiExpression=true
    shift
  fi

  DEBUG subject="type handling" Log "START ANALYZING: ($type) $variableName $@"
  DEBUG subject="type handling" Log "WHAT: $(declare -p $variableName)"

  # Log multiExpression $multiExpression

  if [[ $# -gt 0 ]]
  then
    local method
    local -a params
    local mode=method
    local prevMode
    local prevModeNext
    local treatTheRestAsParams=true
    local bracketsStarted=false
    local -i closingBracketCount=0

    while [[ $# -gt 0 ]]
    do
      prevModeNext=$mode
      # if [[ "$1" == '@' ]]
      # then
      #   # mode=method
      #   treatTheRestAsParams=true
      # el
      if [[ $multiExpression == 'true' ]] && [[ "$1" == '{' ]]
      then
        if [[ $bracketsStarted == 'true' ]]
        then
          ## handle edge case of '}' as actual parameter
          while (( closingBracketCount+=-1 ))
          do
            params+=( '}' )
          done

          Type::RunCurrentStack
        fi
        bracketsStarted=true
        # treatTheRestAsParams=false
        # mode=params
      elif [[ $multiExpression == 'true' ]] && [[ "$1" == '}' ]]
      then
        closingBracketCount+=1
        mode=method
        prevModeNext=params
      elif [[ "$mode" == 'params' ]]
      then
        params+=("$1")
      elif [[ "$mode" == 'method' ]]
      then
        # Log $(@get __${type}_property_names | array.indexOf $1) $1 idx
        # Log $(@get __${type}_property_names | array.contains $1 && echo t)
        local typeSanitized=$(string::SanitizeForVariableName $type)
        # local typeSanitized="${type//[^a-zA-Z0-9]/_}"

        if Variable::Exists __${typeSanitized}_property_names &&
            @get __${typeSanitized}_property_names | array.contains $1
        then
          # stack now belongs to:
          ### selecting property:
          local property="$1"

          DEBUG Log found index __${type}_property_names $(@get __${type}_property_names | __return_self_and_result=false array.indexOf $property)
          # Log prop: $property of [$(@get __${type}_property_names)]

          ## TODO: teoretically we can get rid of: __return_self_and_result=false
          local -i index=$(@get __${typeSanitized}_property_names | __return_self_and_result=false array.indexOf $property)

          if [[ $index -ge 0 ]]
          then
            DEBUG Log "traversing to a child property $property of type $type"

            local newType=__${typeSanitized}_property_types[$index]
            type=${!newType}
            local typeParam=$(Variable::GetDeclarationFlagFromType $type)

            ## TODO: check if this preserves spaces correctly
            local propertyValueIndirect=$variableName[$property]

            if [[ -z "${!propertyValueIndirect}" && "$typeParam" =~ [aA] ]]
            then
              local -$typeParam "__$property=()"
            else
              local -$typeParam "__$property=${!propertyValueIndirect}"

              if ! Type::IsPrimitive "$type"
              then
                eval "__$property[__object_type]=\"\$type\""
              fi
            fi

            DEBUG Log ".$property new $type value is: " # ${propertyValueIndirect} vs '${!propertyValueIndirect}'
            DEBUG Log "$(declare -p __$property)"
            # affectTheInitialVariable=false

            ## TODO: variableName needs to be unique (add count at the end)
            ## in case the same property is nested
            variableName=__$property

            propertyTree+=("$property")

            prevModeNext=property
          fi
          ### /selectProperty
        else
          if [[ "$treatTheRestAsParams" == 'true' ]]
          then
            mode=params
          elif [[ "$prevMode" == 'method' ]]
          then
            Type::RunCurrentStack
          fi
          method="$1"

        fi
      fi
      prevMode=$prevModeNext

      DEBUG subject="type handling" Log "iter: $1 | prevMode: $prevMode | mode: $mode | type: $type | variable: $variableName | method: $method | #params: ${#params[@]}"

      shift
    done

    if [[ "${#method}" -gt 0 ]]
    then
      if [[ "$mode" == 'method' || "$treatTheRestAsParams" == 'true' ]]
      then
        Type::RunCurrentStack
      fi
    elif [[ "$prevMode" == 'property' ]]
    then
      DEBUG subject='property' Log 'print out the property' $variableName
      ## print out the property
      @get $variableName
    fi

    ## TODO: shouldn't this be an elif ?
    # finally echo the latest return value if not empty
    if [[ ! -z "$returnValueDefinition" ]]
    then
      echo "$returnValueDefinition"
    fi

    local -i propertyTreeLength=${#propertyTree[@]}
    if [[ ${#propertyTree[@]} -gt 1 ]]
    then
      # Log PropertyTree: $(@get propertyTree)
      local -a reversedPropertyTree=$(@get propertyTree | __return_self_and_result=false array.reverse)

      local -i i=$propertyTreeLength
      local property
      local parent
      for parent in "${reversedPropertyTree[@]}"
      do
        ## recursively insert the children into parents

        i+=-1
        (( $i == $propertyTreeLength - 1 )) && property=$parent && continue

        local parentVarName=__$parent

        (( $i == 0 )) && parentVarName=$parent

        local propertyDefinition="$(@get __$property)"
        # Log "Will eval: $parentVarName[$property]=\"\$propertyDefinition\""
        eval "$parentVarName[$property]=\"\$propertyDefinition\""

        DEBUG Log "SETTING: ($i) $parentVarName.$property = \"$propertyDefinition\""

        property=$parent
      done
    fi
  else
    @get $variableName
  fi
}

## note: declaration needs to be trimmed,
## since bash adds an enter at the end, hence %?
alias @resolve:this="
  local __local_return_self_and_result=false
  [[ \$__return_self_and_result == 'true' ]] && local __local_return_self_and_result=true && local __return_self_and_result=false
  # TODO: local __access_private_members_of=
  if [[ -z \${__use_this_natively+x} ]];
  then
    local __declaration;
    local __declaration_type;

    if [[ ! -z \"\${useReturnValueDefinition}\" ]];
    then
      # subject='@resolve:this' Log 'using: ReturnValueDefinition'
      # local __declaration_type;
      __declaration=\"\$returnValueDefinition\"
      __declaration_type=\$returnValueType
    elif [[ -z \${thisReference+x} ]];
    then
      # subject='@resolve:this' Log 'using: pipe'
      Pipe::Capture __declaration;
      # local
      __declaration_type=\${FUNCNAME[0]%.*}
      DEBUG Log capturing via pipe \${__declaration_type}
    else
      # subject='@resolve:this' Log 'using: thisReference:' $ \$thisReference type: \$thisReferenceType
      Variable::ExportDeclarationAndTypeToVariables \$thisReference __declaration;
      # local
      __declaration_type=\"\$thisReferenceType\"
      unset thisReference;
    fi;

    local typeParam=\$(Variable::GetDeclarationFlagFromType \"\${__declaration_type}\" '-');
    # subject='@resolve:this' Log \$__declaration_type = \$typeParam = \$__declaration

    local -\$typeParam this=\${__declaration};

    ## add type for objects that don't have them set explicitly
    if [[ \$typeParam == 'A' && \$__declaration_type != 'map' && -z \${this[__object_type]+x} ]]
    then
      # Log setting object type
      this[__object_type]=\"\$__declaration_type\"
    fi

    unset __declaration;
    unset __declaration_type;
  fi
  "


# ------------------------ #