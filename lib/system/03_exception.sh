alias throw="__EXCEPTION_TYPE__=\"\$_\" command_not_found_handle"

command_not_found_handle() {
    # ignore the error from the catch subshell itself
    if [[ "$*" = '( set -e; trap "Exception.Capture ${LINENO}; " ERR;'* ]]
    then
        return 0
    fi

    local script="${BASH_SOURCE[1]#./}"
    local lineNo="${BASH_LINENO[0]}"
    local undefinedObject="$*"
    local type="${__EXCEPTION_TYPE__:-"UNDEFINED COMMAND"}"

    local merger=''
    if [[ ! "$type" = " " ]]
    then
        merger=': '
    fi

    if [[ $__oo__insideTryCatch -gt 0 ]]
    then
        Log.Debug 3 "inside Try Number $__oo__insideTryCatch"
        echo "$undefinedObject" > /tmp/stored_exception
        echo "$lineNo" > /tmp/stored_exception_line
#        echo "$script" > /tmp/stored_exception_source
        return 1
    fi

    if [[ $BASH_SUBSHELL -ge 20 ]]
    then
        echo "ERROR: Call stack exceeded (20)."
        Exception.ContinueOrBreak || exit 1
    fi

    Log.Write
    Log.Write " $(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Bold)UNCAUGHT EXCEPTION${merger}$(UI.Color.LightRed)${type}$(UI.Color.Default)"
    Log.Write "$(Exception.FormatException "$script" "$lineNo" "$undefinedObject")"
    Log.Write "$(Exception.FormatBacktrace 3)"

    Exception.ContinueOrBreak
}

Exception.FormatBacktrace() {
    @int backtraceLevel=2

    declare -a traceLine
    declare -a traceCommand
    declare -a traceFile
    declare -i traceCount

    Exception.GetBacktrace ${backtraceLevel} traceLine traceCommand traceFile traceCount

    local index=1

    while [[ $traceCount -ge $index ]]
    do
        echo "$(Exception.FormatException "${traceFile[$index]}" "${traceLine[$index]}" "${traceCommand[($index - 1)]}" $(($index + 1)) )"
        index+=1
    done
}

Exception.FormatException() {
    @var script
    @var lineNo
    @var stringToMark
    @int callPosition=1

    local errLine="$(sed "${lineNo}q;d" "$script")"

    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    local stringToMarkWithoutSlash="${stringToMark/$slash$slash/$slashReplacement}"
    errLine="${errLine/$slash$slash/$slashReplacement}"

    local underlinedObject="$(UI.Color.LightGreen)$(UI.Powerline.RefersTo) $(UI.Color.Magenta)$(UI.Color.Underline)$stringToMark$(UI.Color.White)$(UI.Color.NoUnderline)"
    local underlinedObjectInLine="${errLine/$stringToMarkWithoutSlash/$underlinedObject}"

    # Bring back the slash:
    underlinedObjectInLine="${underlinedObjectInLine/$slashReplacement/$slash}"
    underlinedObjectInLine="${underlinedObjectInLine#"${underlinedObjectInLine%%[![:space:]]*}"}" # trimming

    # Cut out the path, leave the script name
    script="${script##*/}"

    local prefix="   $(UI.Powerline.Branch)$(String.GetXSpaces $(($callPosition * 3 - 3)) || true)) "
    if [[ ! "$errLine" == *"$stringToMarkWithoutSlash"* ]]
    then
        echo "${prefix}$(UI.Color.White)${underlinedObject}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
        prefix="$prefix$(UI.Powerline.Fail) "
    fi
    echo "${prefix}$(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
}

Exception.ContinueOrBreak()
{
    ## TODO: Exceptions that happen in commands that are piped to others do not HALT the execution
    ## TODO: Add a workaround for this ^

    # if in a terminal
    if [ -t 0 ]
    then
        Log.Write
        Log.Write " $(UI.Color.Yellow)$(UI.Powerline.Lightning)$(UI.Color.White) Press $(UI.Color.Bold)[CTRL+C]$(UI.Color.White) to exit or $(UI.Color.Bold)[Return]$(UI.Color.White) to continue execution."
        read -s
        Log.Write " $(UI.Color.Blue)$(UI.Powerline.Cog)$(UI.Color.White) Continuing...$(UI.Color.Default)"
        return 0
        Log.Write
    else
        Log.Write
        exit 1
    fi
}

Exception.GetBacktrace()
{
    @int startFrom
    @reference line
    @reference call
    @reference filename
    @reference element

    # inspired by: http://stackoverflow.com/questions/64786/error-handling-in-bash

    local -i i=0

    element=0

    while caller $i > /dev/null
    do
        if test -n "$startFrom" && (( "$i" + 1 >= "$startFrom" ))
        then
            local -a trace=( $(caller $i) )

            line[$element]="${trace[0]}"
            call[$element]="${trace[1]}"
            filename[$element]="${trace[@]:2}"

            element+=1

            # caller $i
        fi

        i+=1
    done
}
