#!/usr/bin/env bash

shopt -s expand_aliases

function echo_stderr {
  echo "$*" >&2
}

function assignTrap {
  local evalString
  local -i paramIndex=${__paramIndex-0}
  local initialCommand="${1-}"
  # echo_stderr initialCommand: "$initialCommand"

  if [[ "$initialCommand" != ":" ]]
  then
    # echo_stderr "Removing trap."
    echo "trap - DEBUG; eval \"${__previousTrap}\"; unset __previousTrap; unset __paramIndex;"
    return
  fi

  while [[ "${1-}" == "," || "${1-}" == "${initialCommand}" ]] || [[ "${#@}" -gt 0 && "$paramIndex" -eq 0 ]]
  do
    shift # first colon ":" or next parameter's comma ","
    paramIndex+=1
    # echo_stderr ParamIndex: "$paramIndex"
    local -a decorators=()
    while [[ "${1-}" == "@"* ]]
    do
      decorators+=( "$1" )
      shift
    done

    local declaration=
    local wrapLeft='"'
    local wrapRight='"'
    local nextType="$1"
    local length=1

    case ${nextType} in
      string | boolean) declaration="local " ;;
      integer) declaration="local -i" ;;
      reference) declaration="local -n" ;;
      arrayDeclaration) declaration="local -a"; wrapLeft= ; wrapRight= ;;
      assocDeclaration) declaration="local -A"; wrapLeft= ; wrapRight= ;;
      "string["*"]") declaration="local -a"; length="${nextType//[a-z\[\]]}" ;;
      "integer["*"]") declaration="local -ai"; length="${nextType//[a-z\[\]]}" ;;
    esac

    if [[ "${declaration}" != "" ]]
    then
      shift
      local nextName="$1"
      local handleless=

      for decorator in "${decorators[@]}"
      do
        case ${decorator} in
          @readonly) declaration+="r" ;;
          @required) evalString+="[[ ! -z \$${paramIndex} ]] || echo_stderr \"Parameter '$nextName' ($nextType) is marked as required by '${FUNCNAME[1]}' function.\"; " ;;
          @handleless) handleless=1 ;;
          @global) declaration+="g" ;;
        esac
      done

      local paramRange="$paramIndex"

      if [[ -z "$length" ]]
      then
        # ...rest
        paramRange="{@:$paramIndex}"
        # trim leading ...
        nextName="${nextName//\./}"
        if [[ "${#@}" -gt 1 ]]
        then
          echo_stderr "Unexpected arguments after a rest array ($nextName) in '${FUNCNAME[1]}' function."
        fi
      elif [[ "$length" -gt 1 ]]
      then
        paramRange="{@:$paramIndex:$length}"
        paramIndex+=$((length - 1))
      fi

      # echo_stderr paramRange $paramRange

      evalString+="${declaration} ${nextName}=${wrapLeft}\$${paramRange}${wrapRight}; "

      # if [[ "$handleless" != 1 ]]
      # then
      #   evalString+="Type::CreateHandlerFunction \"$nextName\"; "
      # fi

      # continue to the next param:
      shift
    fi
  done
  # echo_stderr "evaling $evalString"
  echo "${evalString} local -i __paramIndex=${paramIndex};"
}

alias args='local __previousTrap=$(trap -p DEBUG); trap "eval \"\$(assignTrap \$BASH_COMMAND)\";" DEBUG;'

function example { args : @required string firstName , string lastName , integer age } {
  echo "My name is ${firstName} ${lastName} and I am ${age} years old."
}

function example {
  args
    : @required string firstName
    : string lastName
    : integer age
    : string[] ...favoriteHobbies

  echo "My name is ${firstName} ${lastName} and I am ${age} years old."
  echo "My favorite hobbies include: ${favoriteHobbies[*]}"
}

example Mark McDonald 32 singing jumping


function q {
   args : @required string command
   echo "${command-UNDEFINED}"
}
q 'some value'
