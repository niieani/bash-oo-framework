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
