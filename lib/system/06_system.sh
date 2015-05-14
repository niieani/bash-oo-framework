Log.NameScope oo/system

System.LoadFile(){
    @var libPath

    if [ -f "$libPath" ]
    then
        ## if already imported let's return
        if Array.Contains "$file" "${__oo__importedFiles[@]}"
        then
            subject=level3 Log "File previously imported: ${libPath}"
            return 0
        fi

        subject=level2 Log "Importing: $libPath"

        __oo__importedFiles+=( "$libPath" )

        source "$libPath" || throw "Unable to load $libPath"

        # TODO: maybe only Type.Load when the filename starts with a capital?
        # In that case all the types would have to start with a capital letter

        if Function.Exists Type.Load
        then
            Type.Load
            subject=level3 Log "Loading Types..."
        fi
    else
        subject=level2 Log "File doesn't exist when importing: $libPath"
    fi
}

System.Import() {
    local libPath
    for libPath in "$@"; do
        local requestedPath="$libPath"

        ## correct path if relative
        [ ! -e "$libPath" ] && libPath="${__oo__path}/${libPath}"
        [ ! -e "$libPath" ] && libPath="${libPath}.sh"

        subject=level4 Log "Trying to load from: ${__oo__path} / ${requestedPath}"

        if [ ! -e "$libPath" ]
        then
            # try a relative reference
#            local localPath="${BASH_SOURCE[1]%/*}"
            local localPath="$( cd "${BASH_SOURCE[1]%/*}" && pwd )"
#            [ -f "$localPath" ] && localPath="$(dirname "$localPath")"
            libPath="${localPath}/${requestedPath}"
            subject=level4 Log "Trying to load from: ${localPath} / ${requestedPath}"

            [ ! -e "$libPath" ] && libPath="${libPath}.sh"
        fi

        subject=level3 Log "Trying to load from: ${libPath}"
        [ ! -e "$libPath" ] && throw "Cannot import $libPath" && return 1

        libPath="$(File.GetAbsolutePath "$libPath")"

        if [ -d "$libPath" ]; then
            local file
            for file in "$libPath"/*.sh
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
