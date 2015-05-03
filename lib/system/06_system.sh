System.LoadFile(){
    local libPath="$1"
    if [ -f "$libPath" ]
    then
        ## if already imported let's return
        if Array.Contains "$file" "${__oo__importedFiles[@]}"
        then
            Log.Debug 3 "File previously imported: ${libPath}"
            return 0
        fi

        Log.Debug 2 "Importing: $libPath"

        __oo__importedFiles+=( "$libPath" )

        source "$libPath" || throw "Unable to load $libPath"

        # TODO: maybe only Type.Load when the filename starts with a capital?
        # In that case all the types would have to start with a capital letter

        if Function.Exists Type.Load
        then
            Type.Load
            Log.Debug 3 "Loading Types..."
        fi
    else
        Log.Debug 2 "File doesn't exist when importing: $libPath"
    fi
}

System.Import() {
    local libPath
    for libPath in "$@"; do
        local requestedPath="$libPath"

        ## correct path if relative
        [ ! -e "$libPath" ] && libPath="${__oo__path}/${libPath}"
        [ ! -e "$libPath" ] && libPath="${libPath}.sh"

        Log.Debug 4 "Trying to load from: ${__oo__path} / ${requestedPath}"

        if [ ! -e "$libPath" ]
        then
            # try a relative reference
#            local localPath="${BASH_SOURCE[1]%/*}"
            local localPath="$( cd "$( echo "${BASH_SOURCE[1]%/*}" )"; pwd )"
#            [ -f "$localPath" ] && localPath="$(dirname "$localPath")"
            libPath="${localPath}/${requestedPath}"
            Log.Debug 4 "Trying to load from: ${localPath} / ${requestedPath}"

            [ ! -e "$libPath" ] && libPath="${libPath}.sh"
        fi

        Log.Debug 3 "Trying to load from: ${libPath}"
        [ ! -e "$libPath" ] && throw "Cannot import $libPath" && return 1

        libPath="$(File.GetAbsolutePath "$libPath")"

        if [ -d "$libPath" ]; then
            local file
            for file in $libPath/*.sh
            do
                System.LoadFile "$file"
            done
        else
            System.LoadFile "$libPath"
        fi
    done
    return 0
}

alias import="System.Import"
