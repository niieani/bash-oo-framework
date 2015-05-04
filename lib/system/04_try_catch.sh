declare -ig __oo__insideTryCatch=0

# in case try-catch is nested, we set +e before so the parent handler doesn't catch us instead
alias try="[[ \$__oo__insideTryCatch -gt 0 ]] && set +e;
           __oo__insideTryCatch+=1; ( set -e;
		   trap \"Exception.Capture \${LINENO}; \" ERR;"
alias catch=" ); Exception.Extract \$? || "

Exception.Capture() {
    local script="${BASH_SOURCE[1]#./}"

    if [[ ! -f /tmp/stored_exception_source ]]; then
        echo "$script" > /tmp/stored_exception_source
    fi
    if [[ ! -f /tmp/stored_exception_line ]]; then
        echo "$1" > /tmp/stored_exception_line
    fi
    return 0
}

Exception.Extract() {
    if [[ $__oo__insideTryCatch -gt 1 ]]
    then
        set -e
    fi

    __oo__insideTryCatch+=-1

    __EXCEPTION_CATCH__=( $(Exception.GetLastException) )

    local retVal=$1
    if [[ $retVal -gt 0 ]]
    then
        # BACKWARDS COMPATIBILE WAY:
#        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-1)]}"
#        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-2)]}"
        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[-1]}"
        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[-2]}"
        export __EXCEPTION__="${__EXCEPTION_CATCH__[@]:0:(${#__EXCEPTION_CATCH__[@]} - 2)}"
        return 1 # so that we may continue with a "catch"
    fi
}

Exception.GetLastException() {
    if [[ -f /tmp/stored_exception ]] && [[ -f /tmp/stored_exception_line ]] && [[ -f /tmp/stored_exception_source ]]
    then
        cat /tmp/stored_exception
        cat /tmp/stored_exception_line
        cat /tmp/stored_exception_source
    else
        echo -e " \n${BASH_LINENO[1]}\n${BASH_SOURCE[2]#./}"
    fi

    rm -f /tmp/stored_exception /tmp/stored_exception_line /tmp/stored_exception_source
    return 0
}
