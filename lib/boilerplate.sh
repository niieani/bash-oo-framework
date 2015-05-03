shopt -s expand_aliases

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail

# http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE[1]##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
#export PS4='';

declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects
declare -A __oo__objects_private
declare -a __oo__functionsTernaryOperator
declare -g __oo__logger=${LOGGER:-STDERR}
declare -a __oo__importedFiles
declare -ig __oo__insideTryCatch=0
declare -g __EXCEPTION_HANDLED__=false

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
    # ignore the error from the catch subshell itself
    if [[ "$*" = '( set -e; trap "saveThrowLine ${LINENO}; " ERR;'* ]]
    then
        return 0
    fi
#    if [[ $__EXCEPTION_HANDLED__ = true ]]
#    then
#        declare -g __EXCEPTION_HANDLED__=false
#        return 0
#    fi

    local script="${BASH_SOURCE[1]#./}"
    local lineNo=${BASH_LINENO[0]}
    local type="UNCAUGHT EXCEPTION"
    if [[ $__oo__insideTryCatch -gt 0 ]]
    then
#        echo yes, we are inside throw: "$*"
        echo "$*" > /tmp/stored_exception
        echo $lineNo > /tmp/stored_exception_line
#        echo "$script" > /tmp/stored_exception_source
        return 1
    fi
    if [[ $BASH_SUBSHELL -ge 20 ]]
    then
        echo "ERROR: Call stack exceeded (20)."
        echo "Press [CTRL+C] to exit or [Return] to continue execution."
        read
        return 1
    fi

    Log.Write " $(UI.Color.Red)$(UI.Powerline.Fail) EXCEPTION$(UI.Color.Default)"
    Log.Write "$(formatLine "$script" "$lineNo" "$*")"

    Log.Write "$(formatBacktrace 3)"

#    if Function.Exists UI.Color.Default
#    then
#        Log.Write "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.Red)$(UI.Color.Blink)[$type] $(UI.Color.NoBlink)$(UI.Color.White)$*$(UI.Color.Default)"
#    else
#        Log.Write "[${script}:${lineNo}] [$type] $*"
#    fi

    #backtrace 3

    Log.Write "Press [CTRL+C] to exit or [Return] to continue execution."
    read
    return 0
    #return 1
}

formatBacktrace() {

    # TODO: DRY
    declare -a trace
    declare -i index=0
    declare -i traceNo=0
    local i
    for i in $(backtrace ${1:-2})
    do
        index+=1
        if [[ $index -gt 3 ]]; then
            traceNo+=1
            index=1
        fi
        trace[$traceNo]+="$i
"
#        Log.Write backtrace no $traceNo "$i"
    done

    #traceNo+=1
    index=1

    while [[ $traceNo -ge $index ]]
    do
        local thisTrace=(${trace[$index]})
        local prevTrace=(${trace[($index-1)]})

        if [[ ${thisTrace[1]} = main ]]
        then
            thisTrace[2]=$(File.GetAbsolutePath "${thisTrace[2]}")
        fi

#        Log.Write ${thisTrace[@]}
#        Log.Write vs
#        Log.Write ${prevTrace[@]}
#        Log.Write
#        Log.Write "Requesting ${thisTrace[2]}" "${thisTrace[0]}" "${prevTrace[1]}"

        echo "$(formatLine "${thisTrace[2]}" "${thisTrace[0]}" "${prevTrace[1]}" $(expr $index + 1) )"
        index+=1
    done
}

formatLine() {
    local script="$1"
    local lineNo="$2"
    local stringToMark="$3"
    declare -i callPosition="${4:-1}"
    local errLine="$(sed "${lineNo}q;d" "$script")"

    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash='\'
    local slashReplacement='^ORIGINALLY^SLASH^'
    local stringToMarkWithoutSlash="${stringToMark/$slash$slash/$slashReplacement}"
    errLine="${errLine/$slash$slash/$slashReplacement}"

    #Log.Write from: $script @ $lineNo - mark - "$stringToMark"

#    echo errLine "$errLine"
    local underlinedObject="$(UI.Color.LightGreen)$(UI.Powerline.RefersTo) $(UI.Color.Magenta)$(UI.Color.Underline)$stringToMark$(UI.Color.White)$(UI.Color.NoUnderline)"
    #underlinedObject="${underlinedObject/$slashReplacement/$slash}"
    #echo "'$stringToMark'"

    local underlinedObjectInLine="${errLine/$stringToMarkWithoutSlash/$underlinedObject}"
    underlinedObjectInLine="${underlinedObjectInLine#"${underlinedObjectInLine%%[![:space:]]*}"}" # trimming
#    echo underlined $underlinedObjectInLine
    script="${script##*/}"

    local prefix="   $(UI.Powerline.Branch)$(String.GetXSpaces $(expr $callPosition \* 3 - 3 || true)) "
    if [[ ! "$errLine" == *"$stringToMarkWithoutSlash"* ]]
    then
        echo "${prefix}$(UI.Color.White)${underlinedObject}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
        prefix="$prefix$(UI.Powerline.Fail) "
    fi
    echo "${prefix}$(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
}

command_not_found_handle() {
#    declare -g __EXCEPTION_HANDLED__=true
    local script="${BASH_SOURCE[1]#./}"
    local lineNo=${BASH_LINENO[0]}
    local undefinedObject=$*
    if [[ $__oo__insideTryCatch -gt 0 ]]
    then
#        echo inside Try Number $__oo__insideTryCatch
        echo "$undefinedObject is undefined" > /tmp/stored_exception
        echo $lineNo > /tmp/stored_exception_line
#        echo "$script" > /tmp/stored_exception_source
        return 1
    fi
    if [[ $BASH_SUBSHELL -ge 20 ]]
    then
        echo "ERROR: Call stack exceeded (20)."
        echo "Press [CTRL+C] to exit or [Return] to continue execution."
        read
        return 1
    fi

    Log.Write " $(UI.Color.Red)$(UI.Powerline.Fail) UNDEFINED OBJECT EXCEPTION$(UI.Color.Default) $undefinedObject"
    Log.Write "$(formatLine "$script" "$lineNo" "$undefinedObject")"

    #script="${script#./}"
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

    Log.Write "$(formatBacktrace 3)"

    Log.Write "Press [CTRL+C] to exit or [Return] to continue execution."
    read

    #return 127
}


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
#
# FUNCTION: BACKTRACE
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

backtrace()
{
    local _start_from_=0

    local params=( "$@" )
    if (( "${#params[@]}" >= "1" ))
        then
            _start_from_="$1"
    fi

    local i=0
    local first=false
    while caller $i > /dev/null
    do
        if test -n "$_start_from_" && (( "$i" + 1   >= "$_start_from_" ))
            then
                if test "$first" == false
                    then
#                        echo "BACKTRACE IS:"
                        first=true
                fi
                caller $i
                #Log.Write $(caller $i)
        fi
        let "i=i+1"
    done
}