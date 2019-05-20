#!/usr/bin/env bats

export SUITE='named parameters'

. vendor/bats-support/load.bash
. vendor/bats-assert/load.bash
. src/core/namedParameters.sh

@test "$SUITE: string - declare empty parameter" {
  f() {
    [string] str
    declare -p str
  }

  run f
  assert_output 'declare -- str'
}

@test "$SUITE: string - declare parameter with default value" {
  f() {
    [string] str='value'
    declare -p str
  }

  run f
  assert_output 'declare -- str="value"'
}

@test "$SUITE: string - declare parameter with passed value" {
  f() {
    [string] str='value'
    declare -p str
  }

  run f 'passed'
  assert_output 'declare -- str="passed"'
}

@test "$SUITE: integer - declare empty parameter" {
  f() {
    [integer] int
    declare -p int
  }

  run f
  assert_output 'declare -i int'
}

@test "$SUITE: integer - declare parameter with default value" {
  f() {
    [integer] int=5
    declare -p int
  }

  run f
  assert_output 'declare -i int="5"'
}

@test "$SUITE: integer - declare parameter with passed value" {
  f() {
    [integer] int=5
    declare -p int
  }

  run f 10
  assert_output 'declare -i int="10"'
}

@test "$SUITE: integer - fail when passing wrong type to parameter" {
  f() {
    [integer] int=5
    declare -p int
  }

  run f 'string'
  assert_failure
}

@test "$SUITE: fail when a required parameter is not given" {
  f() {
    @required [integer] int
  }

  run f 'string'
  assert_failure
}

@test "$SUITE: internal variables do not leak" {
  f() {
    (set -o posix; set)
    @required [integer] int
  }

  run f 5

  num_of_vars_before="${#lines[@]}"
  unset output

  readarray -t num_of_vars_after <<< "$(set -o posix; set)"
  num_of_vars_after="${#num_of_vars_after[@]}"

  assert_equal "$num_of_vars_before" "$num_of_vars_after"
}

@test "$SUITE: multiple declarations at once" {
  f() {
    @required [integer] int
    @required [string] str
    [string] str2='qwerty'
    [integer] int2

    declare -p int str str2 int2
  }

  run f 10 'string'

  match="declare -i int=\"10\"%"
  match+="declare -- str=\"string\"%"
  match+="declare -- str2=\"qwerty\"%"
  match+="declare -i int2"

  assert_output "${match//%/$'\n'}"
}

@test "$SUITE: arguments are shifted correctly" {
  f() {
    @required [integer] int
    @required [string] str
    [string] str2='qwerty'
    [integer] int2

    echo "$#"
  }

  run f 10 'string' 'string2' 20 spare1 spare2 spare3


  assert_output "3"
}
