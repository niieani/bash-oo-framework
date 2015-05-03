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

        # TODO: this might not be necessary
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
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    local stringToMarkWithoutSlash="${stringToMark/$slash$slash/$slashReplacement}"
    errLine="${errLine/$slash$slash/$slashReplacement}"

    #Log.Write from: $script @ $lineNo - mark - "$stringToMark"

#    echo errLine "$errLine"
    local underlinedObject="$(UI.Color.LightGreen)$(UI.Powerline.RefersTo) $(UI.Color.Magenta)$(UI.Color.Underline)$stringToMark$(UI.Color.White)$(UI.Color.NoUnderline)"

    #echo "'$stringToMark'"

    local underlinedObjectInLine="${errLine/$stringToMarkWithoutSlash/$underlinedObject}"
    # Bring back the slash:
    underlinedObjectInLine="${underlinedObjectInLine/$slashReplacement/$slash}"
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

    continueOrBreak
    #return 127
}

continueOrBreak()
{
    Log.Write "Press [CTRL+C] to exit or [Return] to continue execution."
    read -s
    Log.Write "Continuing..."
    Log.Write
}


###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
#
# FUNCTION: BACKTRACE
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

backtrace()
{
    local _start_from_=${1:-0}

#    local params=( "$@" )
#    if (( "${#params[@]}" >= "1" ))
#        then
#            _start_from_="$1"
#    fi

    declare -i i=0
    local first=false
    while caller $i > /dev/null
    do
        if test -n "$_start_from_" && (( "$i" + 1 >= "$_start_from_" ))
        then
            if test "$first" == false
            then
                first=true
            fi
            caller $i
        fi
        i+=1
#        let "i=i+1"
    done
}
