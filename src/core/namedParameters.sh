#!/usr/bin/env bash

set -ue
shopt -s expand_aliases

# Inspired by
# https://web.archive.org/web/20150910160505/https://simpletondigest.wordpress.com/2012/01/06/building-a-better-macro/
alias __bash_oo_namedParameters_d='CMD="${BASH_COMMAND#*#\'\''}" eval '\''eval "$(eval "__bash_oo_namedParameters_declarator $CMD \"\$@\" || echo return 1")"; [[ "$#" -gt 0 ]] && shift || : #'\'

alias @required='required=true'
alias [string]='__bash_oo_namedParameters_d string'
alias [integer]='__bash_oo_namedParameters_d integer'

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
      declaration="declare $variable_name${value:+=$value}"
      ;;
    'integer')
      if [[ ! "${value:-1}" =~ [0-9]+ ]]; then
        return 1
      fi
      declaration="declare -i $variable_name${value:+=$value}"
      ;;
  esac

  printf "$declaration"
}
