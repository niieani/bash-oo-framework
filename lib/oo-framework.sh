###########################
### BOOTSTRAP FUNCTIONS ###
###########################

if [[ -n "$__INTERNAL_LOGGING__" ]]
then
  alias DEBUG=":; "
else
  alias DEBUG=":; #"
fi

System::Import() {
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
        System::LoadFile "$file"
      done
    else
      System::LoadFile "$libPath"
    fi
  done
  return 0
}

File::GetAbsolutePath() {
  # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  # $1 : relative filename
  local file="$1"
  if [[ "$file" == "/"* ]]
  then
    echo "$file"
  else
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  fi
}

System::LoadFile(){
  local libPath="$1"
  #    [string] libPath

  if [ -f "$libPath" ]
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

    # eval "$(<"$libPath")"
    source "$libPath" || throw "Unable to load $libPath"
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

declare -g __oo__bootstrapped=true
