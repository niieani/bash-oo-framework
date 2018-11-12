# no dependencies
declare -ig __oo__insideTryCatch=0
declare -g __oo__presetShellOpts="$-"

# in case try-catch is nested, we set +e before so the parent handler doesn't catch us instead
alias try='[[ $__oo__insideTryCatch -eq 0 ]] || __oo__presetShellOpts="$(echo $- | sed 's/[is]//g')"; __oo__insideTryCatch+=1; set +e; ( set -e; true; '
alias catch='); declare __oo__tryResult=$?; __oo__insideTryCatch+=-1; [[ $__oo__insideTryCatch -lt 1 ]] || set -${__oo__presetShellOpts:-e} && Exception::Extract $__oo__tryResult || '

Exception::SetupTemp() {
  declare -g __oo__storedExceptionLineFile="$(mktemp -t stored_exception_line.$$.XXXXXXXXXX)"
  declare -g __oo__storedExceptionSourceFile="$(mktemp -t stored_exception_source.$$.XXXXXXXXXX)"
  declare -g __oo__storedExceptionBacktraceFile="$(mktemp -t stored_exception_backtrace.$$.XXXXXXXXXX)"
  declare -g __oo__storedExceptionFile="$(mktemp -t stored_exception.$$.XXXXXXXXXX)"
}

Exception::CleanUp() {
  local exitVal=$?
  rm -f $__oo__storedExceptionLineFile $__oo__storedExceptionSourceFile $__oo__storedExceptionBacktraceFile $__oo__storedExceptionFile || exit 1
  exit $exitVal
}

Exception::ResetStore() {
  > $__oo__storedExceptionLineFile
  > $__oo__storedExceptionFile
  > $__oo__storedExceptionSourceFile
  > $__oo__storedExceptionBacktraceFile
}

Exception::GetLastException() {
  if [[ -s $__oo__storedExceptionFile ]]
  then
    cat $__oo__storedExceptionLineFile
    cat $__oo__storedExceptionFile
    cat $__oo__storedExceptionSourceFile
    cat $__oo__storedExceptionBacktraceFile

    Exception::ResetStore
  else
    echo -e "${BASH_LINENO[1]}\n \n${BASH_SOURCE[2]#./}"
  fi
}

Exception::Extract() {
  local retVal=$1
  unset __oo__tryResult

  if [[ $retVal -gt 0 ]]
  then
    local IFS=$'\n'
    __EXCEPTION__=( $(Exception::GetLastException) )

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

Exception::SetupTemp
trap Exception::CleanUp EXIT INT TERM
