#!/usr/bin/env bash
# oo-framework version: ea7c3af
###########################
### BOOTSTRAP FUNCTIONS ###
###########################

System.Bootstrap(){
    local file
    local path
    for file in "$__oo__libPath"/system/*.sh
    do
        path="$(File.GetAbsolutePath "$file")"
        __oo__importedFiles+=( "$path" )

        ## note: aliases are visible inside functions only if
        ## they were initialized AFTER they were created
        ## this is the reason why we have to load lib/system/* in a specific order (numbers)
        if ! source "$path"
        then
            cat <<< "FATAL ERROR: Unable to bootstrap (loading $libPath)" 1>&2
            exit 1
        fi
    done
}

File.GetAbsolutePath() {
    # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
    # $1 : relative filename
    if [[ "$file" == "/"* ]]
    then
        echo "$file"
    else
        echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    fi
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
declare -g __oo__libPath="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
declare -g __oo__path="${__oo__libPath}/.."
declare -ag __oo__importedFiles


#########################
### HANDLE EXCEPTIONS ###
#########################

trap "__EXCEPTION_TYPE__=\"\$_\" command_not_found_handle \$BASH_COMMAND" ERR
set -o errtrace  # trace ERR through 'time command' and other functions
declare -Ag __oo__logScopes
declare -Ag __oo__logScopeOutputs
declare -Ag __oo__logDisabledFilter
declare -Ag __oo__loggers

Log.NameScope() {
    local scopeName="$1"
    local script="${BASH_SOURCE[1]}"
    __oo__logScopes["$script"]="$scopeName"
}
alias namespace="Log.NameScope"

Log.AddOutput() {
    local scopeName="$1"
    local outputType="${2:-STDERR}"
    __oo__logScopeOutputs["$scopeName"]+="$outputType;"
}

Log.ResetOutputsAndFilters() {
    local scopeName="$1"
    unset __oo__logScopeOutputs["$scopeName"]
    unset __oo__logDisabledFilter["$scopeName"]
}

Log.ResetAllOutputsAndFilters() {
    unset __oo__logScopeOutputs
    unset __oo__logDisabledFilter
    declare -Ag __oo__logScopeOutputs
    declare -Ag __oo__logDisabledFilter
}

Log.DisableFilter() {
    __oo__logDisabledFilter["$1"]=true
}

Log() {
    local callingFunction="${FUNCNAME[1]}"
    local callingScript="${BASH_SOURCE[1]}"
    local scope
    if [[ ! -z "${__oo__logScopes["$callingScript"]}" ]]
    then
        scope="${__oo__logScopes["$callingScript"]}"
    else # just the filename without extension
        scope="${callingScript##*/}"
        scope="${scope%.*}"
    fi
    local loggerList
    local loggers
    local logger
    local logged
    
    if [[ ! -z "$subject" ]]
    then
        if [[ ! -z "${__oo__logScopeOutputs["$scope/$callingFunction/$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$callingFunction/$subject"]}"
        elif [[ ! -z "${__oo__logScopeOutputs["$scope/$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$subject"]}"
        elif [[ ! -z "${__oo__logScopeOutputs["$subject"]}" ]]
        then
            loggerList="${__oo__logScopeOutputs["$subject"]}"
        fi
        
        loggers=( ${loggerList//;/ } )
        for logger in "${loggers[@]}"
        do
            Log.Using "$logger" "$@"
            logged=true
        done
    fi
    
    if [[ ! -z "${__oo__logScopeOutputs["$scope/$callingFunction"]}" ]]
    then
        if [[ -z $logged ]] || [[ ${__oo__logDisabledFilter["$scope/$callingFunction"]} == true || ${__oo__logDisabledFilter["$scope"]} == true ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope/$callingFunction"]}"
            loggers=( ${loggerList//;/ } )
            for logger in "${loggers[@]}"
            do
                Log.Using "$logger" "$@"
                logged=true
            done
        fi
    fi
    
    if [[ ! -z "${__oo__logScopeOutputs["$scope"]}" ]]
    then
        if [[ -z $logged ]] || [[ ${__oo__logDisabledFilter["$scope"]} == true ]]
        then
            loggerList="${__oo__logScopeOutputs["$scope"]}"
            loggers=( ${loggerList//;/ } )
            for logger in "${loggers[@]}"
            do
                Log.Using "$logger" "$@"
            done
        fi
    fi
}

Log.RegisterLogger() {
    local logger="$1"
    local method="$2"
    __oo__loggers["$logger"]="$method"
}

Log.Using() {
    local logger="$1"
    shift
    if [[ ! -z ${__oo__loggers["$logger"]} ]]
    then
        ${__oo__loggers["$logger"]} "$@"
    fi
}

Console.WriteStdErr() {
    # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
    cat <<< "$*" 1>&2
    return 0
}

Console.WriteStdErrAnnotated() {
    local script="$1"
    local lineNo=$2
    local color=$3
    local type=$4
    shift; shift; shift; shift

    Console.WriteStdErr "$color[$type] $(UI.Color.Blue)[${script}:${lineNo}]$(UI.Color.Default) $* "
}

Logger.DEBUG() {
    Console.WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) DEBUG "$@"
}
Logger.ERROR() {
    Console.WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Red) ERROR "$@"
}
Logger.INFO() {
    Console.WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Blue) INFO "$@"
}
Logger.WARN() {
    Console.WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) WARN "$@"
}
Logger.CUSTOM() {
    Console.WriteStdErrAnnotated "${BASH_SOURCE[3]##*/}" ${BASH_LINENO[2]} $(UI.Color.Yellow) "${subject^^}" "$@"
}

Log.RegisterLogger STDERR Console.WriteStdErr
Log.RegisterLogger DEBUG Logger.DEBUG
Log.RegisterLogger ERROR Logger.ERROR
Log.RegisterLogger INFO Logger.INFO
Log.RegisterLogger WARN Logger.WARN
Log.RegisterLogger CUSTOM Logger.CUSTOM
Log.RegisterLogger DETAILED Logger.DETAILED

alias Error="subject=error Log"

namespace oo/log

alias UI.Color.IsAvailable='[[ "${TERM}" == *"xterm"* ]] && [ -t 1 ]'
if UI.Color.IsAvailable
then
    alias UI.Color.Default="echo \$'\033[0m'"

    alias UI.Color.Black="echo \$'\033[0;30m'"
    alias UI.Color.Red="echo \$'\033[0;31m'"
    alias UI.Color.Green="echo \$'\033[0;32m'"
    alias UI.Color.Yellow="echo \$'\033[0;33m'"
    alias UI.Color.Blue="echo \$'\033[0;34m'"
    alias UI.Color.Magenta="echo \$'\033[0;35m'"
    alias UI.Color.Cyan="echo \$'\033[0;36m'"
    alias UI.Color.LightGray="echo \$'\033[0;37m'"

    alias UI.Color.DarkGray="echo \$'\033[0;90m'"
    alias UI.Color.LightRed="echo \$'\033[0;91m'"
    alias UI.Color.LightGreen="echo \$'\033[0;92m'"
    alias UI.Color.LightYellow="echo \$'\033[0;93m'"
    alias UI.Color.LightBlue="echo \$'\033[0;94m'"
    alias UI.Color.LightMagenta="echo \$'\033[0;95m'"
    alias UI.Color.LightCyan="echo \$'\033[0;96m'"
    alias UI.Color.White="echo \$'\033[0;97m'"

    # flags
    alias UI.Color.Bold="echo \$'\033[1m'"
    alias UI.Color.Dim="echo \$'\033[2m'"
    alias UI.Color.Underline="echo \$'\033[4m'"
    alias UI.Color.Blink="echo \$'\033[5m'"
    alias UI.Color.Invert="echo \$'\033[7m'"
    alias UI.Color.Invisible="echo \$'\033[8m'"

    alias UI.Color.NoBold="echo \$'\033[21m'"
    alias UI.Color.NoDim="echo \$'\033[22m'"
    alias UI.Color.NoUnderline="echo \$'\033[24m'"
    alias UI.Color.NoBlink="echo \$'\033[25m'"
    alias UI.Color.NoInvert="echo \$'\033[27m'"
    alias UI.Color.NoInvisible="echo \$'\033[28m'"
else
    alias UI.Color.Default="echo"

    alias UI.Color.Black="echo"
    alias UI.Color.Red="echo"
    alias UI.Color.Green="echo"
    alias UI.Color.Yellow="echo"
    alias UI.Color.Blue="echo"
    alias UI.Color.Magenta="echo"
    alias UI.Color.Cyan="echo"
    alias UI.Color.LightGray="echo"

    alias UI.Color.DarkGray="echo"
    alias UI.Color.LightRed="echo"
    alias UI.Color.LightGreen="echo"
    alias UI.Color.LightYellow="echo"
    alias UI.Color.LightBlue="echo"
    alias UI.Color.LightMagenta="echo"
    alias UI.Color.LightCyan="echo"
    alias UI.Color.White="echo"

    # flags
    alias UI.Color.Bold="echo"
    alias UI.Color.Dim="echo"
    alias UI.Color.Underline="echo"
    alias UI.Color.Blink="echo"
    alias UI.Color.Invert="echo"
    alias UI.Color.Invisible="echo"

    alias UI.Color.NoBold="echo"
    alias UI.Color.NoDim="echo"
    alias UI.Color.NoUnderline="echo"
    alias UI.Color.NoBlink="echo"
    alias UI.Color.NoInvert="echo"
    alias UI.Color.NoInvisible="echo"
fi

alias UI.Powerline.IsAvailable="test -z $NO_UNICODE && (echo -e $'\u1F3B7' | grep -v F3B7) &> /dev/null"
if UI.Powerline.IsAvailable
then
	alias UI.Powerline.PointingArrow="echo -e $'\u27a1'"
	alias UI.Powerline.ArrowLeft="echo -e $'\ue0b2'"
	alias UI.Powerline.ArrowRight="echo -e $'\ue0b0'"
	alias UI.Powerline.ArrowRightDown="echo -e $'\u2198'"
	alias UI.Powerline.ArrowDown="echo -e $'\u2B07'"
	alias UI.Powerline.PlusMinus="echo -e $'\ue00b1'"
	alias UI.Powerline.Branch="echo -e $'\ue0a0'"
	alias UI.Powerline.RefersTo="echo -e $'\u27a6'"
	alias UI.Powerline.OK="echo -e $'\u2714'"
	alias UI.Powerline.Fail="echo -e $'\u2718'"
	alias UI.Powerline.Lightning="echo -e $'\u26a1'"
	alias UI.Powerline.Cog="echo -e $'\u2699'"
	alias UI.Powerline.Heart="echo -e $'\u2764'"

	# colorful
	alias UI.Powerline.Star="echo -e $'\u2b50'"
	alias UI.Powerline.Saxophone="echo -e $'\U1F3B7'"
	alias UI.Powerline.ThumbsUp="echo -e $'\U1F44D'"
else
	alias UI.Powerline.PointingArrow="echo '~'"
	alias UI.Powerline.ArrowLeft="echo '<'"
	alias UI.Powerline.ArrowRight="echo '>'"
	alias UI.Powerline.ArrowRightDown="echo '>'"
	alias UI.Powerline.ArrowDown="echo '_'"
	alias UI.Powerline.PlusMinus="echo '+-'"
	alias UI.Powerline.Branch="echo '|}'"
	alias UI.Powerline.RefersTo="echo '*'"
	alias UI.Powerline.OK="echo '+'"
	alias UI.Powerline.Fail="echo 'x'"
	alias UI.Powerline.Lightning="echo '!'"
	alias UI.Powerline.Cog="echo '{*}'"
	alias UI.Powerline.Heart="echo '<3'"

	# colorful
	alias UI.Powerline.Star="echo '*''"
	alias UI.Powerline.Saxophone="echo '(YEAH)'"
	alias UI.Powerline.ThumbsUp="echo '(OK)'"
fi
namespace oo

Function.AssignParamLocally() {
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'
    
    local commandWithArgs=( $1 )
    local command="${commandWithArgs[0]}"

    shift

    if [[ "$command" == "trap" || "$command" == "l="* || "$command" == "_type="* ]]
    then
        return 0
    fi

    if [[ "${commandWithArgs[*]}" == "true" ]]
    then
        __assign_next=true
        # Console.WriteStdErr "Will assign next one"

        local nextAssignment=$(( ${__assign_paramNo:-0} + 1 ))
        if [[ "${!nextAssignment}" == "$ref:"* ]]
        then
            # Console.WriteStdErr param is a reference: $nextAssignment
            __assign_isReference="-n"
        else
            __assign_isReference=""
        fi
        return 0
    fi

    local varDeclaration="${commandWithArgs[1]}"
    if [[ $varDeclaration == '-'* || $varDeclaration == '${'* ]]
    then
        varDeclaration="${commandWithArgs[2]}"
    fi
    local varName="${varDeclaration%%=*}"

    # var value is only important if making an object later on from it
    local varValue="${varDeclaration#*=}"
    # TODO: checking for parameter existance or default value

    if [[ ! -z $__assign_varType ]]
    then
        # Console.WriteStdErr "SETTING $__assign_varName = \$$__assign_paramNo"
        # Console.WriteStdErr --

        local execute

        if [[ "$__assign_varType" == "array" ]]
        then
            # passing array:
            execute="$__assign_varName=( \"\${@:$__assign_paramNo:$__assign_arrLength}\" )"
            eval "$execute"
            __assign_paramNo+=$(($__assign_arrLength - 1))

            unset __assign_arrLength
        elif [[ "$__assign_varType" == "params" ]]
        then
            execute="$__assign_varName=( \"\${@:$__assign_paramNo}\" )"
            eval "$execute"
        elif [[ "$__assign_varType" == "reference" ]]
        then
            execute="$__assign_varName=\"\$$__assign_paramNo\""
            eval "$execute"
        elif [[ ! -z "${!__assign_paramNo}" ]]
        then
            if [[ "${!__assign_paramNo}" == "$ref:"* ]]
            then
                local refVarName="${!__assign_paramNo#$ref:}"
                execute="$__assign_varName=$refVarName"
            else
                execute="$__assign_varName=\"\$$__assign_paramNo\""
            fi

            # Console.WriteStdErr "EXECUTE $execute"
            eval "$execute"
        fi
        unset __assign_varType
        unset __assign_isReference
    fi

    if [[ "$command" != "local" || "$__assign_next" != "true" ]]
    then
        __assign_normalCodeStarted+=1

        # Console.WriteStdErr "NOPASS ${commandWithArgs[*]}"
        # Console.WriteStdErr "normal code count ($__assign_normalCodeStarted)"
        # Console.WriteStdErr --
    else
        unset __assign_next

        __assign_normalCodeStarted=0
        __assign_varName="$varName"
        __assign_varType="$__capture_type"
        __assign_arrLength="$__capture_arrLength"

        # Console.WriteStdErr "PASS ${commandWithArgs[*]}"
        # Console.WriteStdErr --

        __assign_paramNo+=1
    fi
}

Function.CaptureParams() {
    # Console.WriteStdErr "Capturing Type $_type"
    # Console.WriteStdErr --

    __capture_type="$_type"
    __capture_arrLength="$l"
    
    #__assign_OLDIFS=$IFS
    #IFS=$__oo__originalIFS
}
    
# NOTE: true; true; at the end is required to workaround an edge case where TRAP doesn't behave properly
alias @trapAssign='Function.CaptureParams; declare -i __assign_normalCodeStarted=0; trap "declare -i __assign_paramNo; Function.AssignParamLocally \"\$BASH_COMMAND\" \"\$@\"; [[ \$__assign_normalCodeStarted -ge 2 ]] && trap - DEBUG && unset __assign_varType && unset __assign_varName && unset __assign_paramNo" DEBUG; true; true; '
alias @param='@trapAssign local'
alias @reference='_type=reference @trapAssign local -n'
alias @var="_type=var @trapAssign local \${__assign_isReference}"
alias @int='_type=int @trapAssign local -i'
alias @params='_type=params @param'
alias @array='_type=array @param'
alias @array[2]='l=2 _type=array @param'
alias @array[3]='l=3 _type=array @param'
alias @array[4]='l=4 _type=array @param'
alias @array[5]='l=5 _type=array @param'
alias @array[6]='l=6 _type=array @param'
alias @array[7]='l=7 _type=array @param'
alias @array[8]='l=8 _type=array @param'
alias @array[9]='l=9 _type=array @param'
alias @array[10]='l=10 _type=array @param'

declare -g ref=$'\UEFF1A'$'\UEFF1A'

namespace oo

alias throw="__EXCEPTION_TYPE__=\${e:-Manually invoked} command_not_found_handle"

command_not_found_handle() {
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'
    
    # ignore the error from the catch subshell itself
    if [[ "$*" = '( set -e; true'* ]]
    then
        return 0
    fi

    local script="${BASH_SOURCE[1]#./}"
    local lineNo="${BASH_LINENO[0]}"
    local undefinedObject="$*"
    local type="${__EXCEPTION_TYPE__:-"Undefined command"}"

    if [[ "$undefinedObject" == "("*")" ]]
    then
        type="Subshell returned a non-zero value"
    fi

    if [[ -z "$undefinedObject" ]]
    then
        undefinedObject="$type"
    fi

    if [[ $__oo__insideTryCatch -gt 0 ]]
    then
        subject=level3 Log "inside Try No.: $__oo__insideTryCatch"

        if [[ ! -s $__oo__storedExceptionLineFile ]]; then
            echo "$lineNo" > $__oo__storedExceptionLineFile
        fi
        if [[ ! -s $__oo__storedExceptionFile ]]; then
            echo "$undefinedObject" > $__oo__storedExceptionFile
        fi
        if [[ ! -s $__oo__storedExceptionSourceFile ]]; then
            echo "$script" > $__oo__storedExceptionSourceFile
        fi
        if [[ ! -s $__oo__storedExceptionBacktraceFile ]]; then
            Exception.DumpBacktrace 2 > $__oo__storedExceptionBacktraceFile
        fi
        
        return 1 # needs to be return 1
    fi

    if [[ $BASH_SUBSHELL -ge 25 ]]
    then
        echo "ERROR: Call stack exceeded (25)."
        Exception.ContinueOrBreak || exit 1
    fi

    local -a exception=( "$lineNo" "$undefinedObject" "$script" )
    
    local IFS=$'\n'
    for traceElement in $(Exception.DumpBacktrace 2)
    do
        exception+=( "$traceElement" )
    done
    IFS=$' \t\n'

    Console.WriteStdErr
    Console.WriteStdErr " $(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Bold)UNCAUGHT EXCEPTION: $(UI.Color.LightRed)${type}$(UI.Color.Default)"
    Exception.PrintException "${exception[@]}"

    Exception.ContinueOrBreak
}

Exception.SetupTemp() {
    declare -g __oo__storedExceptionLineFile="$(mktemp -t stored_exception_line.$$.XXXXXXXXXX)"
    declare -g __oo__storedExceptionSourceFile="$(mktemp -t stored_exception_source.$$.XXXXXXXXXX)"
    declare -g __oo__storedExceptionBacktraceFile="$(mktemp -t stored_exception_backtrace.$$.XXXXXXXXXX)"
    declare -g __oo__storedExceptionFile="$(mktemp -t stored_exception.$$.XXXXXXXXXX)"
}

Exception.SetupTemp

Exception.CleanUp() {
    rm -f $__oo__storedExceptionLineFile $__oo__storedExceptionSourceFile $__oo__storedExceptionBacktraceFile $__oo__storedExceptionFile || exit 1
    exit 0
}

Exception.ResetStore() {
    > $__oo__storedExceptionLineFile
    > $__oo__storedExceptionFile
    > $__oo__storedExceptionSourceFile
    > $__oo__storedExceptionBacktraceFile
}

trap Exception.CleanUp EXIT INT TERM

Exception.GetLastException() {
    if [[ -s $__oo__storedExceptionFile ]]
    then
        cat $__oo__storedExceptionLineFile
        cat $__oo__storedExceptionFile
        cat $__oo__storedExceptionSourceFile
        cat $__oo__storedExceptionBacktraceFile
        
        Exception.ResetStore
    else
        echo -e "${BASH_LINENO[1]}\n \n${BASH_SOURCE[2]#./}"
    fi
}

Exception.PrintException() {
    @params exception
    
    local -i backtraceIndentationLevel=${backtraceIndentationLevel:-0}
    
    local -i counter=0
    local -i backtraceNo=0
    
    local -a backtraceLine
    local -a backtraceCommand
    local -a backtraceFile
    
    #for traceElement in Exception.GetLastException
    while [[ $counter -lt ${#exception[@]} ]]
    do
        backtraceLine[$backtraceNo]="${exception[$counter]}"
        counter+=1
        backtraceCommand[$backtraceNo]="${exception[$counter]}"
        counter+=1
        backtraceFile[$backtraceNo]="${exception[$counter]}"
        counter+=1
        
        backtraceNo+=1
    done
    
    local -i index=1
    
    while [[ $index -lt $backtraceNo ]]
    do
        Console.WriteStdErr "$(Exception.FormatExceptionSegment "${backtraceFile[$index]}" "${backtraceLine[$index]}" "${backtraceCommand[($index - 1)]}" $(( $index + $backtraceIndentationLevel )) )"
        index+=1
    done
}

Exception.CanHighlight() {
    @var errLine
    @var stringToMark
    
    local stringToMarkWithoutSlash="$(String.ReplaceSlashes "$stringToMark")"
    errLine="$(String.ReplaceSlashes "$errLine")"
    
    if [[ "$errLine" == *"$stringToMarkWithoutSlash"* ]]
    then
        return 0
    else
        return 1
    fi
}

Exception.HighlightPart() {
    @var errLine
    @var stringToMark
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local stringToMarkWithoutSlash="$(String.ReplaceSlashes "$stringToMark")"
    errLine="$(String.ReplaceSlashes "$errLine")"
    
    local underlinedObject="$(Exception.GetUnderlinedPart "$stringToMark")"
    local underlinedObjectInLine="${errLine/$stringToMarkWithoutSlash/$underlinedObject}"

    # Bring back the slash:
    underlinedObjectInLine="$(String.BringBackSlashes "$underlinedObjectInLine")"
    
    # Trimming:
    underlinedObjectInLine="${underlinedObjectInLine#"${underlinedObjectInLine%%[![:space:]]*}"}" # "

	echo "$underlinedObjectInLine"
}

Exception.GetUnderlinedPart() {
    @var stringToMark
    
    echo "$(UI.Color.LightGreen)$(UI.Powerline.RefersTo) $(UI.Color.Magenta)$(UI.Color.Underline)$stringToMark$(UI.Color.White)$(UI.Color.NoUnderline)"
}

Exception.FormatExceptionSegment() {
    @var script
    @int lineNo
    @var stringToMark
    @int callPosition=1

    local errLine="$(sed "${lineNo}q;d" "$script")"
    local originalErrLine="$errLine"
    
    local -i linesTried=0
    
    # In case it's a multiline eval, sometimes bash gives a line that's offset by a few
    while [[ $linesTried -lt 5 && $lineNo -gt 0 ]] && ! Exception.CanHighlight "$errLine" "$stringToMark"
    do
        linesTried+=1
        lineNo+=-1
        errLine="$(sed "${lineNo}q;d" "$script")"
    done

    # Cut out the path, leave the script name
    script="${script##*/}"
    
    local prefix="   $(UI.Powerline.Branch)$(String.GetXSpaces $(($callPosition * 3 - 3)) || true) "
    
    if [[ $linesTried -ge 5 ]]
    then
        # PRINT THE ORGINAL OBJECT AND ORIGINAL LINE #
        #local underlinedObject="$(Exception.HighlightPart "$errLine" "$stringToMark")"
        local underlinedObject="$(Exception.GetUnderlinedPart "$stringToMark")"
        echo "${prefix}$(UI.Color.White)${underlinedObject}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
        prefix="$prefix$(UI.Powerline.Fail) "
        errLine="$originalErrLine"
    fi
    
    local underlinedObjectInLine="$(Exception.HighlightPart "$errLine" "$stringToMark")"
    
    echo "${prefix}$(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default) [$(UI.Color.Blue)${script}:${lineNo}$(UI.Color.Default)]"
}

Exception.ContinueOrBreak()
{
    ## TODO: Exceptions that happen in commands that are piped to others do not HALT the execution
    ## TODO: Add a workaround for this ^

    # if in a terminal
    if [ -t 0 ]
    then
        Console.WriteStdErr
        Console.WriteStdErr " $(UI.Color.Yellow)$(UI.Powerline.Lightning)$(UI.Color.White) Press $(UI.Color.Bold)[CTRL+C]$(UI.Color.White) to exit or $(UI.Color.Bold)[Return]$(UI.Color.White) to continue execution."
        read -s
        Console.WriteStdErr " $(UI.Color.Blue)$(UI.Powerline.Cog)$(UI.Color.White) Continuing...$(UI.Color.Default)"
        return 0
        Console.WriteStdErr
    else
        Console.WriteStdErr
        exit 1
    fi
}

Exception.DumpBacktrace()
{
    @int startFrom=1
    # inspired by: http://stackoverflow.com/questions/64786/error-handling-in-bash
    
    # USE DEFAULT IFS IN CASE IT WAS CHANGED - important!
    local IFS=$' \t\n'
    
    local -i i=0

    while caller $i > /dev/null
    do
        if (( $i + 1 >= $startFrom ))
        then
            local -a trace=( $(caller $i) )
            
            echo "${trace[0]}"
            echo "${trace[1]}"
            echo "${trace[@]:2}"
        fi
        i+=1
    done
}

namespace oo

declare -ig __oo__insideTryCatch=0

# in case try-catch is nested, we set +e before so the parent handler doesn't catch us instead
alias try='[[ $__oo__insideTryCatch -eq 0 ]] || set +e; __oo__insideTryCatch+=1; ( set -e; true; '
alias catch='); declare __oo__tryResult=$?; __oo__insideTryCatch+=-1; [[ $__oo__insideTryCatch -lt 1 ]] || set -e; Exception.Extract $__oo__tryResult || '

Exception.Extract() {
    local retVal=$1
    
    if [[ $retVal -gt 0 ]]
    then
        local IFS=$'\n'
        __EXCEPTION__=( $(Exception.GetLastException) )
        
        local -i counter=0
        local -i backtraceNo=0
        
        while [[ $counter -lt ${#__EXCEPTION__[@]} ]]
        do
            __BACKTRACE_LINE__[$backtraceNo]="${__EXCEPTION__[$counter]}"
            counter+=1
            __BACKTRACE_COMMAND__[$backtraceNo]="${__EXCEPTION__[$counter]}"
            counter+=1
            __BACKTRACE_SOURCE__[$backtraceNo]="${__EXCEPTION__[$counter]}"
            counter+=1
            backtraceNo+=1
        done
        
        return 1 # so that we may continue with a "catch"
    fi
    return 0
}

namespace oo

Array.Contains() {
    local e
    for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done
    return 1
}

String.IsNumber() {
    @var input

    local regex='^-?[0-9]+([.][0-9]+)?$'
    if ! [[ "$input" =~ $regex ]]
    then
        return 1
    fi
    return 0
}

String.GetXSpaces() {
    @var howMany

    if [[ "$howMany" -gt 0 ]]
    then
        ( printf "%*s" "$howMany" )
    fi
    return 0
}

String.ReplaceSlashes() {
    @var stringToMark
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slash$slash/$slashReplacement}"
}

String.BringBackSlashes() {
    @var stringToMark
    
    # Workaround for a Bash bug that causes string replacement to fail when a \ is in the string
    local slash="\\"
    local slashReplacement='_%SLASH%_'
    echo "${stringToMark/$slashReplacement/$slash}"
}

Function.Exists(){
    local name="$1"
    local typeMatch=$(type "$name" 2> /dev/null) || return 1
    echo "$typeMatch" | grep "function\|alias" &> /dev/null || return 1
    return 0
}
alias Object.Exists="Function.Exists"

namespace oo

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

## INFO: aliases need to be loaded from outside, before the types are imported
## unfortunately types cannot import them, because they don't unfold in their scope

## KEYWORDS ##
alias extends="Type.Extend"

# it has to be reversed with ! and logical OR because otherwise we get an exception...
alias method="! [[ -z \$instance || \$instance = false ]] ||"
alias static="! [[ -z \$instance || \$instance = false ]] ||"

alias methods="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~methods="fi"

alias statics="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~statics="fi"

# it has to be reversed with ! and logical OR because otherwise we get an exception...
alias public="[[ \$instance != true ]] || __private__=false "
alias private="[[ \$instance != true ]] || __private__=true "

