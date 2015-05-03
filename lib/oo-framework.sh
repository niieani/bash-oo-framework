shopt -s expand_aliases

#echo $(dirname "${BASH_SOURCE[0]%/*}")
# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in mysqldump | gzip
set -o pipefail

# http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE[1]##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects
declare -A __oo__objects_private
declare -a __oo__functionsTernaryOperator
declare -g __oo__logger=${LOGGER:-STDERR}
declare -a __oo__importedFiles
declare -ig __oo__insideTryCatch=0
declare -g __oo__path="$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )"

## note: aliases are visible inside functions only if
## they were initialized AFTER they were created

File.GetAbsolutePath() {
    # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

System.Bootstrap(){
    local file
    local path
    for file in $__oo__path/system/*.sh
    do
        path="$(File.GetAbsolutePath "$file")"
        __oo__importedFiles+=( "$path" )
        #echo "Loading: $path"
        source "$path" || cat <<< "FATAL ERROR: Unable to bootstrap (loading $libPath)" 1>&2
    done
}

System.Bootstrap

trap "throw \$BASH_COMMAND" ERR
set -o errtrace  # trace ERR through 'time command' and other functions
