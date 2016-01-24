#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-bootstrap.sh"

## MAIN ##

namespace oo

System::LoadFile(){
    [string] libPath

    if [ -f "$libPath" ]
    then
        ## if already imported let's return
        if Array::Contains "$file" "${__oo__importedFiles[@]}"
        then
            DEBUG subject=level3 Log "File previously imported: ${libPath}"
            return 0
        fi

        DEBUG subject=level2 Log "Importing: $libPath"

        __oo__importedFiles+=( "$libPath" )

        source "$libPath" || throw "Unable to load $libPath"

        # TODO: maybe only Type.Load when the filename starts with a capital?
        # In that case all the types would have to start with a capital letter

        if Function::Exists Type.Load
        then
            Type.Load
            DEBUG subject=level3 Log "Loading Types..."
        fi
    else
        :
        DEBUG subject=level2 Log "File doesn't exist when importing: $libPath"
    fi
}

System::Import() {
    local libPath
    for libPath in "$@"; do
        local requestedPath="$libPath"

        ## correct path if relative
        [ ! -e "$libPath" ] && libPath="${__oo__path}/${libPath}"
        [ ! -e "$libPath" ] && libPath="${libPath}.sh"

        DEBUG subject=level4 Log "Trying to load from: ${__oo__path} / ${requestedPath}"

        if [ ! -e "$libPath" ]
        then
            # try a relative reference
#            local localPath="${BASH_SOURCE[1]%/*}"
            local localPath="$( cd "${BASH_SOURCE[1]%/*}" && pwd )"
#            [ -f "$localPath" ] && localPath="$(dirname "$localPath")"
            libPath="${localPath}/${requestedPath}"
            DEBUG subject=level4 Log "Trying to load from: ${localPath} / ${requestedPath}"

            [ ! -e "$libPath" ] && libPath="${libPath}.sh"
        fi

        DEBUG subject=level3 Log "Trying to load from: ${libPath}"
        [ ! -e "$libPath" ] && throw "Cannot import $libPath" && return 1

        libPath="$(File::GetAbsolutePath "$libPath")"

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

alias import="System::Import"
