shopt -s expand_aliases

declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects
declare -A __oo__objects_private
declare -a __oo__functionsTernaryOperator
declare -g __oo__logger=${LOGGER:-STDERR}
declare -a __oo__importedFiles

# these will be unaliased when they're loaded
#alias Log.Debug="echo"
#alias Log.Debug:1="echo"
#alias Log.Debug:2="echo"
#alias Log.Debug:3="echo"
Log.Debug() { echo "$@"; }
Log.Debug:1() { echo "$@"; }
Log.Debug:1() { echo "$@"; }
Log.Debug:1() { echo "$@"; }
Function.Exists() { return 1; }

File.GetAbsolutePath() {
    # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

import() {
    local localPath="${BASH_SOURCE[1]%/*}"
    [ -f "$localPath" ] && $localPath=$(dirname "$localPath")

    local libPath
    for libPath in "$@"; do
        local requestedPath="$libPath"

        ## correct path if relative
        [ ! -e "$libPath" ] && libPath="${__oo__path}/${libPath}"
        [ ! -e "$libPath" ] && libPath="${libPath}.sh"

        [ ! -e "$libPath" ] && libPath="${localPath}/${requestedPath}"
        [ ! -e "$libPath" ] && libPath="${libPath}.sh"

        [ ! -e "$libPath" ] && throw "cannot import $libPath" && return 1

        libPath="$(File.GetAbsolutePath "$libPath")"

        local inArrayPath

        if [ -d "$libPath" ]; then
            local file
            for file in $libPath/*.sh
            do
                ## if already imported let's return
                for inArrayPath in "${__oo__importedFiles[@]}"
                do [[ "$inArrayPath" == "$file" ]] && Log.Debug "$file was already imported." && return 0; done

                Log.Debug "Importing: $file"
                __oo__importedFiles+=( "$file" )
                source "$file"
                Function.Exists Type.Load && Log.Debug "Loading Types..." && Type.Load
            done
        elif [ -f "$libPath" ]; then
            ## if already imported let's return
            for inArrayPath in "${__oo__importedFiles[@]}"
            do [[ "$inArrayPath" == "$libPath" ]] && Log.Debug "$libPath was already imported." && return 0; done

            Log.Debug "Importing: $libPath"
            __oo__importedFiles+=( "$libPath" )
            source "$libPath"
            Function.Exists Type.Load && Log.Debug "Loading Types..." && Type.Load
        fi
    done
    return 0
}

throw() {
    local script="${BASH_SOURCE[1]#./}"
    local lineNo=${BASH_LINENO[0]}
    local type="EXCEPTION"
    if Function.Exists UI.Color
    then
        Log.Debug "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.Red)$(UI.Color.Blink)[$type] $(UI.Color.NoBlink)$(UI.Color.White)$*$(UI.Color.Default)"
    else
        Log.Debug "[${script}:${lineNo}] [$type] $*"
    fi
    Log.Debug "Press [CTRL+C] to exit or [Return] to continue execution."
    read
    return 1
}

command_not_found_handle() {
    local script="${BASH_SOURCE[1]#./}"
    local lineNo=${BASH_LINENO[0]}
    local undefinedObject=$*
    #script="${script#./}"
    if Function.Exists UI.Color
    then
        local errLine=$(sed "${lineNo}q;d" "$script")
        local underlinedObject="$(UI.Color.Magenta)$(UI.Color.Underline)$undefinedObject"$(UI.Color.White)$(UI.Color.NoUnderline)
        local underlinedObjectInLine="${errLine/$undefinedObject/$underlinedObject}"
        underlinedObjectInLine="$(String.Trim "$underlinedObjectInLine")"
        Log.Debug
        Log.Debug "$(UI.Color.Red)Undefined object:"
        Log.Debug "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default)"
        Log.Debug
    else
        Log.Debug "[${script}:${lineNo}] Undefined object: $undefinedObject"
    fi
    return 127
}
