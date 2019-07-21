#!/usr/bin/env bash

set -ue
shopt -s expand_aliases

# Inspired by
# https://web.archive.org/web/20150910160505/https://simpletondigest.wordpress.com/2012/01/06/building-a-better-macro/
alias __bash_oo_namedParameters_d='CMD="${BASH_COMMAND#*#\'\''}" eval '\''eval "$(eval "__bash_oo_namedParameters_declarator $CMD \"\$@\" || echo return 1")"; [[ "$#" -gt 0 ]] && shift || : #'\'

alias @required='required=true'
alias [string]='__bash_oo_namedParameters_d string'
alias [integer]='__bash_oo_namedParameters_d integer'
alias [boolean]='__bash_oo_namedParameters_d boolean'
# alias [array]='__bash_oo_namedParameters_d array'
# alias [map]='__bash_oo_namedParameters_d map'
# alias [string[]]='__bash_oo_namedParameters_d params'
# alias [string[1]]='__bash_oo_namedParameters_d params l=1'
# alias [string[2]]='__bash_oo_namedParameters_d params l=2'
# alias [string[3]]='__bash_oo_namedParameters_d params l=3'
# alias [string[4]]='__bash_oo_namedParameters_d params l=4'
# alias [string[5]]='__bash_oo_namedParameters_d params l=5'
# alias [string[6]]='__bash_oo_namedParameters_d params l=6'
# alias [string[7]]='__bash_oo_namedParameters_d params l=7'
# alias [string[8]]='__bash_oo_namedParameters_d params l=8'
# alias [string[9]]='__bash_oo_namedParameters_d params l=9'
# alias [string[10]]='__bash_oo_namedParameters_d params l=10'
alias [...rest]='__bash_oo_namedParameters_d rest'

# Namespaced function name
function __bash_oo_namedParameters_declarator() {
  local type="$1"
  local argument="$2"
  shift 2

  local variable_name="${argument%%=*}"

  local value
  if [[ "${argument#*=}" == "$argument" ]]; then
    value=''
  else
    value="${argument#*=}"
  fi

  declare -p value

  if [[ "$#" -gt 0 ]]; then
    value="$1"
  fi

  if [[ "${required-false}" == true && ! -v value ]]; then
    return 1
  fi

  local declaration
  case "$type" in
    'string')
      declaration="declare $variable_name${value:+=\"$value\"}"
      ;;
    'integer')
      if [[ ! "${value:-1}" =~ [0-9]+ ]]; then
        return 1
      fi
      declaration="declare -i $variable_name${value:+=$value}"
      ;;
    'boolean')
      if [[ ! -v value ]]; then
        declaration="declare $variable_name"
      elif [[ "$value" == true ]]; then
        declaration="declare $variable_name=true"
      else
        declaration="declare $variable_name=false"
      fi
      ;;
    'rest')
      if [[ "$#" -gt 0 ]]; then
        declaration="declare -a $variable_name=(\"\$@\")"
      else
        declaration="declare -a $variable_name=()"
      fi
      ;;
  esac

  printf "$declaration"
}
