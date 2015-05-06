declare -ig __oo__insideTryCatch=0

# in case try-catch is nested, we set +e before so the parent handler doesn't catch us instead
#alias try="[[ \$__oo__insideTryCatch -gt 0 ]] && set +e; __oo__insideTryCatch+=1; ( set -e; trap \"Exception.Capture \${LINENO} \\\"\${BASH_COMMAND}\\\" \\\"\${BASH_SOURCE[0]#./}\\\"; \" ERR;"
alias try='[[ $__oo__insideTryCatch -eq 0 ]] || set +e;
           __oo__insideTryCatch+=1;
           ( set -e; '

alias catch='); declare __oo__tryResult=$?; __oo__insideTryCatch+=-1; [[ $__oo__insideTryCatch -lt 1 ]] || set -e; Exception.Extract $__oo__tryResult || '
        
Exception.Extract() {
    #if [[ $__oo__insideTryCatch -gt 1 ]]
    #then
    #    set -e
    #fi

    #__oo__insideTryCatch+=-1


    local retVal=$1
    
    if [[ $retVal -gt 0 ]]
    then
        #declare -a __BACKTRACE_LINE__
        #declare -a __BACKTRACE_COMMAND__
        #declare -a __BACKTRACE_SOURCE__
    
        local IFS=$'\n'
        #local -a 
        __EXCEPTION__=( $(Exception.GetLastException) )
        
        local -i counter=0
        local -i backtraceNo=0
        
        #for traceElement in Exception.GetLastException
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
        # BACKWARDS COMPATIBILE WAY:
#        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-1)]}"
#        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-2)]}"
        #export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[-1]}"
        #export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[-2]}"
        #export __EXCEPTION__="${__EXCEPTION_CATCH__[@]:0:(${#__EXCEPTION_CATCH__[@]} - 2)}"
        return 1 # so that we may continue with a "catch"
    fi
    return 0
}

Exception.GetLastException() {
    if [[ -f /tmp/stored_exception ]] # && [[ -f /tmp/stored_exception_line ]] && [[ -f /tmp/stored_exception_source ]]
    then
        cat /tmp/stored_exception_line
        cat /tmp/stored_exception
        cat /tmp/stored_exception_source
        cat /tmp/stored_exception_backtrace
    else
        echo -e "${BASH_LINENO[1]}\nUNKNOWN\n${BASH_SOURCE[2]#./}"
    fi

    rm -f /tmp/stored_exception /tmp/stored_exception_line /tmp/stored_exception_source /tmp/stored_exception_backtrace # /tmp/stored_exception_alt
    return 0
}


Exception.Capture() {
    if [[ ! -f /tmp/stored_exception_line ]]; then
        echo "$1" > /tmp/stored_exception_line
    fi
    if [[ ! -f /tmp/stored_exception ]]; then
        echo "$2" > /tmp/stored_exception
    #elif [[ ! -f /tmp/stored_exception_alt ]]; then
    #    echo "$2" > /tmp/stored_exception_alt
    fi
    if [[ ! -f /tmp/stored_exception_source ]]; then
        echo "$3" > /tmp/stored_exception_source
    fi

    # Log.Write "$(Exception.FormatBacktrace 3 "$3" "$1" "$2")"

    return 0
}
