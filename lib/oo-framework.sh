###########################
### BOOTSTRAP FUNCTIONS ###
###########################

System::Bootstrap() {
  local file
  local path
  for file in "$__oo__libPath"/util/import.sh
  do
    path="$(File::GetAbsolutePath "$file")"
    # __oo__importedFiles+=( "$path" )

    ## note: aliases are visible inside functions only if
    ## they were initialized AFTER they were created
    ## this is the reason why we have to load lib/system/* in a specific order (numbers)
    if ! source "$path"
    then
      cat <<< "FATAL ERROR: Unable to bootstrap (loading $libPath)" 1>&2
      exit 1
    fi
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
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
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
if [[ -n "$__INTERNAL_LOGGING__" ]]
then
  alias DEBUG=":; "
else
  alias DEBUG=":; #"
fi

## stubs in case either exception or log is not loaded
namespace() { :; }
throw() { eval 'echo "Exception: $e ($*)"; read -s;'; }

System::Bootstrap

declare -g __oo__bootstrapped=true
