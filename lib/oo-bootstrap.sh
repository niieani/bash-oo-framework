#!/usr/bin/env bash

###########################
### BOOTSTRAP FUNCTIONS ###
###########################

if [[ -n "${__INTERNAL_LOGGING__:-}" ]]
then
  alias DEBUG=":; "
else
  alias DEBUG=":; #"
fi

System::SourceHTTP() {
  local URL="$1"
  local -i RETRIES=3
  shift

  if hash curl 2>/dev/null
  then
    builtin source <(curl --fail -sL --retry $RETRIES "${URL}" || { [[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && curl --fail -sL --retry $RETRIES "${URL}.sh"; } || echo "e='Cannot import $URL' throw") "$@"
  else
    builtin source <(wget -t $RETRIES -O - -o /dev/null "${URL}" || { [[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && wget -t $RETRIES -O - -o /dev/null "${URL}.sh"; } || echo "e='Cannot import $URL' throw") "$@"
  fi
  __oo__importedFiles+=( "$URL" )
}

System::SourcePath() {
  local libPath="$1"
  shift
  # echo trying $libPath
  if [[ -d "$libPath" ]]
  then
    local file
    for file in "$libPath"/*.sh
    do
      System::SourceFile "$file" "$@"
    done
  else
    System::SourceFile "$libPath" "$@" || System::SourceFile "${libPath}.sh" "$@"
  fi
}

declare -g __oo__fdPath=$(dirname <(echo))
declare -gi __oo__fdLength=$(( ${#__oo__fdPath} + 1 ))

System::ImportOne() {
  local libPath="$1"
  local __oo__importParent="${__oo__importParent-}"
  local requestedPath="$libPath"
  shift

  if [[ "$requestedPath" == 'github:'* ]]
  then
    requestedPath="https://raw.githubusercontent.com/${requestedPath:7}"
  elif [[ "$requestedPath" == './'* ]]
  then
    requestedPath="${requestedPath:2}"
  elif [[ "$requestedPath" == "$__oo__fdPath"* ]] # starts with /dev/fd
  then
    requestedPath="${requestedPath:$__oo__fdLength}"
  fi

  # [[ "$__oo__importParent" == 'http://'* || "$__oo__importParent" == 'https://'* ]] &&
  if [[ "$requestedPath" != 'http://'* && "$requestedPath" != 'https://'* ]]
  then
    requestedPath="${__oo__importParent}/${requestedPath}"
  fi

  if [[ "$requestedPath" == 'http://'* || "$requestedPath" == 'https://'* ]]
  then
    __oo__importParent=$(dirname "$requestedPath") System::SourceHTTP "$requestedPath"
    return
  fi

  # try relative to parent script
  # try with parent
  # try without parent
  # try global library
  # try local library
  {
    local localPath="$( cd "${BASH_SOURCE[1]%/*}" && pwd )"
    localPath="${localPath}/${libPath}"
    System::SourcePath "${localPath}" "$@"
  } || \
  System::SourcePath "${requestedPath}" "$@" || \
  System::SourcePath "${libPath}" "$@" || \
  System::SourcePath "${__oo__libPath}/${libPath}" "$@" || \
  System::SourcePath "${__oo__path}/${libPath}" "$@" || e="Cannot import $libPath" throw
}

System::Import() {
  local libPath
  for libPath in "$@"
  do
    System::ImportOne "$libPath"
  done
}

File::GetAbsolutePath() {
  # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  # $1 : relative filename
  local file="$1"
  if [[ "$file" == "/"* ]]
  then
    echo "$file"
  else
    echo "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
  fi
}

System::WrapSource() {
  local libPath="$1"
  shift

  builtin source "$libPath" "$@" || throw "Unable to load $libPath"
}

System::SourceFile() {
  local libPath="$1"
  shift

  # DEBUG subject=level3 Log "Trying to load from: ${libPath}"
  [[ ! -f "$libPath" ]] && return 1 # && e="Cannot import $libPath" throw

  libPath="$(File::GetAbsolutePath "$libPath")"

  # echo "importing $libPath"

  # [ -e "$libPath" ] && echo "Trying to load from: ${libPath}"
  if [[ -f "$libPath" ]]
  then
    ## if already imported let's return
    # if declare -f "Array::Contains" &> /dev/null &&
    if [[ "${__oo__allowFileReloading-}" != true ]] && [[ ! -z "${__oo__importedFiles[*]}" ]] && Array::Contains "$libPath" "${__oo__importedFiles[@]}"
    then
      # DEBUG subject=level3 Log "File previously imported: ${libPath}"
      return 0
    fi

    # DEBUG subject=level2 Log "Importing: $libPath"

    __oo__importedFiles+=( "$libPath" )
    __oo__importParent=$(dirname "$libPath") System::WrapSource "$libPath" "$@"
    # eval "$(<"$libPath")"

  else
    :
    # DEBUG subject=level2 Log "File doesn't exist when importing: $libPath"
  fi
}

System::Bootstrap() {
  ## note: aliases are visible inside functions only if
  ## they were initialized AFTER they were created
  ## this is the reason why we have to load files in a specific order
  if ! System::Import Array/Contains
  then
    cat <<< "FATAL ERROR: Unable to bootstrap (missing lib directory?)" 1>&2
    exit 1
  fi
}

########################
### INITIALZE SYSTEM ###
########################

# From: http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error inside pipes, e.g. mysqldump | gzip
set -o pipefail

shopt -s expand_aliases
declare -g __oo__libPath="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
declare -g __oo__path="${__oo__libPath}/.."
declare -ag __oo__importedFiles

## stubs in case either exception or log is not loaded
namespace() { :; }
throw() { eval 'cat <<< "Exception: $e ($*)" 1>&2; read -s;'; }

System::Bootstrap

alias import="__oo__allowFileReloading=false System::Import"
alias source="__oo__allowFileReloading=true System::ImportOne"
alias .="__oo__allowFileReloading=true System::ImportOne"

declare -g __oo__bootstrapped=true
