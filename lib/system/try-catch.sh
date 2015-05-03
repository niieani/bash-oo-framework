# if nested then set +e before so the parent handler doesn't catch us
alias try="[[ \$__oo__insideTryCatch -gt 0 ]] && set +e;
           __oo__insideTryCatch+=1; ( set -e;
		   trap \"saveThrowLine \${LINENO}; \" ERR;"
alias catch=" ); extractException \$? || "

saveThrowLine() {
    #export __THROW_LINE__=$1
    local script="${BASH_SOURCE[1]#./}"
    #    echo MIMI: $script
    if [[ ! -f /tmp/stored_exception_source ]]; then
        echo "$script" > /tmp/stored_exception_source
    fi
    if [[ ! -f /tmp/stored_exception_line ]]; then
        echo "$1" > /tmp/stored_exception_line
    fi
    return 0
}

extractException(){
#    export __EXCEPTION_HANDLED__=false

    if [[ $__oo__insideTryCatch -gt 1 ]]
    then
        set -e
    fi
    __oo__insideTryCatch+=-1

    __EXCEPTION_CATCH__=($(lastException))

    local retVal=$1
    if [[ $retVal -gt 0 ]]
    then
    #${realArray[-1]}
        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[-1]}"
        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[-2]}"
        export __EXCEPTION__="${__EXCEPTION_CATCH__[@]:0:(${#__EXCEPTION_CATCH__[@]} - 2)}"
#        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-1)]}"
#        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-2)]}"
#        export __EXCEPTION__="${__EXCEPTION_CATCH__[@]:0:(${#__EXCEPTION_CATCH__[@]}-2)}"
        return 1 # so that we may continue
    fi
}

lastException() {
    if [[ -f /tmp/stored_exception ]] && [[ -f /tmp/stored_exception_line ]] && [[ -f /tmp/stored_exception_source ]]
    then
#        echo -e "$(cat /tmp/stored_exception)\n$(cat /tmp/stored_exception_line)"
#        echo "$(cat /tmp/stored_exception) $(cat /tmp/stored_exception_line)"
        cat /tmp/stored_exception
        cat /tmp/stored_exception_line
        cat /tmp/stored_exception_source
    else
        echo -e "Unknown Exception\n${BASH_LINENO[1]}\n${BASH_SOURCE[2]#./}"
    fi

    rm -f /tmp/stored_exception /tmp/stored_exception_line /tmp/stored_exception_source
    return 0
}
