shopt -s expand_aliases

declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects
declare -A __oo__objects_private
declare -a __oo__functionsTernaryOperator
declare -g __oo__logger=${LOGGER:-STDERR}
declare -a __oo__importedFiles

## note: aliases are visible inside functions only if
## they were initialized AFTER they were created

File.GetAbsolutePath() {
    # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

System.Load(){
    local file
    local path
    for file in $__oo__path/lib/system/*.sh
    do
        path="$(File.GetAbsolutePath "$file")"
        __oo__importedFiles+=( "$path" )
        #echo "Loading: $path"
        source "$path"
    done
}

System.Load

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
                local isImported=false
                ## if already imported let's return
                for inArrayPath in "${__oo__importedFiles[@]}"
                do
                    Log.Debug:3 inArray Question $inArrayPath vs $file
                    if [[ "$inArrayPath" = "$file" ]]
                    then
                        isImported=true
                    fi
                done

                if [[ "$isImported" = "true" ]]
                then
                    Log.Debug:3 "$file was already imported."
                #                        return 0
                else
                    Log.Debug:3 "Importing: $file"
                    __oo__importedFiles+=( "$file" )
                    source "$file"
                    Function.Exists Type.Load && Log.Debug:4 "Loading Types..." && Type.Load
                fi
            done
        elif [ -f "$libPath" ]; then
            ## if already imported let's return
            for inArrayPath in "${__oo__importedFiles[@]}"
            do [[ "$inArrayPath" == "$libPath" ]] && Log.Debug:4 "$libPath was already imported." && return 0; done

            Log.Debug:3 "Importing: $libPath"
            __oo__importedFiles+=( "$libPath" )
            source "$libPath"
            Function.Exists Type.Load && Log.Debug:4 "Loading Types..." && Type.Load
        fi
    done
    return 0
}

throw() {
    if [[ $BASH_SUBSHELL -ge 20 ]]
    then
        echo "ERROR: Call stack exceeded (20)."
        echo "Press [CTRL+C] to exit or [Return] to continue execution."
        read
        return 1
    fi
    local script="${BASH_SOURCE[1]#./}"
    local lineNo=${BASH_LINENO[0]}
    local type="EXCEPTION"
    if Function.Exists UI.Color.Default
    then
        Log.Write "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.Red)$(UI.Color.Blink)[$type] $(UI.Color.NoBlink)$(UI.Color.White)$*$(UI.Color.Default)"
    else
        Log.Write "[${script}:${lineNo}] [$type] $*"
    fi
    Log.Write "Press [CTRL+C] to exit or [Return] to continue execution."
    read
    return 1
}

#command_not_found_handle() {
#    if [[ $BASH_SUBSHELL -ge 20 ]]
#    then
#        echo "ERROR: Call stack exceeded (20)."
#        echo "Press [CTRL+C] to exit or [Return] to continue execution."
#        read
#        return 1
#    fi
#    local script="${BASH_SOURCE[1]#./}"
#    local lineNo=${BASH_LINENO[0]}
#    local undefinedObject=$*
#    #script="${script#./}"
#    if Function.Exists UI.Color.Default
#    then
#        local errLine=$(sed "${lineNo}q;d" "$script")
#        local underlinedObject="$(UI.Color.Magenta)$(UI.Color.Underline)$undefinedObject"$(UI.Color.White)$(UI.Color.NoUnderline)
#        local underlinedObjectInLine="${errLine/$undefinedObject/$underlinedObject}"
#        underlinedObjectInLine="$(String.Trim "$underlinedObjectInLine")"
#        Log.Write
#        Log.Write "$(UI.Color.Red)Undefined object:"
#        Log.Write "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.Red)$(UI.Color.Blink)[EXCEPTION] $(UI.Color.NoBlink)$(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default)"
#        Log.Write
#    else
#        Log.Write "[${script}:${lineNo}] [EXCEPTION] Undefined object: $undefinedObject"
#    fi
#    return 127
#}
