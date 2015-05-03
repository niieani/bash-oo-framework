###########################
### BOOTSTRAP FUNCTIONS ###
###########################

File.GetAbsolutePath() {
    # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

System.Bootstrap(){
    local file
    local path
    for file in $__oo__path/lib/system/*.sh
    do
        path="$(File.GetAbsolutePath "$file")"
        __oo__importedFiles+=( "$path" )

        ## note: aliases are visible inside functions only if
        ## they were initialized AFTER they were created
        ## this is the reason why we have to load lib/system/* in a specific order (numbers)
        source "$path" || cat <<< "FATAL ERROR: Unable to bootstrap (loading $libPath)" 1>&2
    done
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
declare -g __oo__path="$( cd "$( echo "${BASH_SOURCE[0]%/*}/.." )"; pwd )"
declare -g __oo__logger=${LOGGER:-STDERR}
declare -a __oo__importedFiles
declare -ig __oo__insideTryCatch=0

System.Bootstrap

#########################
### HANDLE EXCEPTIONS ###
#########################

trap "throw \$BASH_COMMAND" ERR
set -o errtrace  # trace ERR through 'time command' and other functions
