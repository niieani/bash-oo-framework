###########################
### BOOTSTRAP FUNCTIONS ###
###########################

if [[ -n "$__INTERNAL_LOGGING__" ]]
then
  alias DEBUG=":; "
else
  alias DEBUG=":; #"
fi

System::ImportOld() {
  local libPath
  for libPath in "$@"; do
    local requestedPath="$libPath"

    [ ! -e "$libPath" ] && libPath="${__oo__libPath}/${libPath}"
    [ ! -e "$libPath" ] && libPath="${libPath}.sh"

    [ ! -e "$libPath" ] && libPath="${__oo__path}/${libPath}"
    [ ! -e "$libPath" ] && libPath="${libPath}.sh"

    # DEBUG subject=level4 Log "Trying to load from: ${__oo__path} / ${requestedPath}"

    ## correct path if relative
    if [ ! -e "$libPath" ]
    then
      # try a relative reference
      #            local localPath="${BASH_SOURCE[1]%/*}"
      local localPath="$( cd "${BASH_SOURCE[1]%/*}" && pwd )"
      #            [ -f "$localPath" ] && localPath="$(dirname "$localPath")"
      libPath="${localPath}/${requestedPath}"
      # DEBUG subject=level4 Log "Trying to load from: ${localPath} / ${requestedPath}"

      [ ! -e "$libPath" ] && libPath="${libPath}.sh"
    fi

    # DEBUG subject=level3 Log "Trying to load from: ${libPath}"
    [ ! -e "$libPath" ] && e="Cannot import $libPath" throw && return 1

    libPath="$(File::GetAbsolutePath "$libPath")"
    # [ -e "$libPath" ] && echo "Trying to load from: ${libPath}"

    if [ -d "$libPath" ]; then
      local file
      for file in "$libPath"/*.sh
      do
        System::SourceFile "$file"
      done
    else
      System::SourceFile "$libPath"
    fi
  done
  return 0
}

###

System::SourceHTTP() {
  local URL="$1"
  local -i RETRIES=3
  shift

  if hash curl 2>/dev/null
  then
    # curl --fail -sL --retry $RETRIES "${URL}" || { [[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && curl --fail -sL --retry $RETRIES "${URL}.sh"; } || echo "e='Cannot import $URL' throw"
    builtin source <(curl --fail -sL --retry $RETRIES "${URL}" || { [[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && curl --fail -sL --retry $RETRIES "${URL}.sh"; } || echo "e='Cannot import $URL' throw") "$@"
    # builtin source <([[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && curl -sL --retry $RETRIES "${URL}.sh" || curl -sL --retry $RETRIES "${URL}" || echo "e='Cannot import $URL' throw") "$@"
  else
    builtin source <(wget -t $RETRIES -O - -o /dev/null "${URL}" || { [[ "$URL" != *'.sh' && "$URL" != *'.bash' ]] && wget -t $RETRIES -O - -o /dev/null "${URL}.sh"; } || echo "e='Cannot import $URL' throw") "$@"
  fi
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
    # if [[ -e "$libPath" ]]
    # then
    #   System::SourceFile "$libPath"
    # elif [[ -e "${libPath}.sh" ]]
    # then
    #   System::SourceFile "${libPath}.sh"
    # else
    #   return 1
    # fi
  fi
}

System::ImportOne() {
  local libPath="$1"
  local __oo__importParent="${__oo__importParent}"
  local requestedPath="$libPath"
  shift

  if [[ "$requestedPath" == 'github:'* ]]
  then
    requestedPath="https://raw.githubusercontent.com/${requestedPath:7}"
  elif [[ "$requestedPath" == './'* ]]
  then
    requestedPath="${requestedPath:2}"
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

  # 1. try with parent
  # 2. try with parent with .sh
  # 3. try without parent
  # 4. try without parent with .sh
  # 5. try global library
  # 6. try global library with .sh
  # 7. try local library
  # 8. try local library with .sh
  # 9. try relative to parent script
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
    if [[ ! -z "${__oo__importedFiles[*]}" ]] && Array::Contains "$file" "${__oo__importedFiles[@]}"
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
export PS4='+(${BASH_SOURCE[1]##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error inside pipes, e.g. mysqldump | gzip
set -o pipefail

shopt -s expand_aliases
declare -g __oo__libPath="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
declare -g __oo__path="${__oo__libPath}/.."
declare -ag __oo__importedFiles

## stubs in case either exception or log is not loaded
namespace() { :; }
throw() { eval 'echo "Exception: $e ($*)"; read -s;'; }

System::Bootstrap

alias import="System::Import"
alias source="System::ImportOne"
alias .="System::ImportOne"

declare -g __oo__bootstrapped=true
