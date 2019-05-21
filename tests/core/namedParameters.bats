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

@test "$SUITE: string - declare parameter with passed value containing spaces" {
  f() {
    [string] str='value'
    declare -p str
  }

  run f 'passed value'
  assert_output 'declare -- str="passed value"'
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

@test "$SUITE: boolean - declare empty parameter as false" {
  f() {
    [boolean] bool
    declare -p bool
  }

  run f
  assert_output 'declare -- bool="false"'
}

@test "$SUITE: boolean - declare parameter with default value" {
  f() {
    [boolean] bool=true
    declare -p bool
  }

  run f
  assert_output 'declare -- bool="true"'
}

@test "$SUITE: boolean - declare parameter with passed value" {
  f() {
    [boolean] bool=false
    declare -p bool
  }

  run f true
  assert_output 'declare -- bool="true"'
}

@test "$SUITE: boolean - declare as false when argument is not true/false" {
  f() {
    [boolean] bool=true
    declare -p bool
  }

  run f 'string'
  assert_output 'declare -- bool="false"'
}

@test "$SUITE: rest - declare parameter with no value" {
  f() {
    [...rest] rest
    declare -p rest
  }

  run f
  assert_output "declare -a rest=()"
}

@test "$SUITE: rest - declare parameter with multiple arguments" {
  f() {
    [...rest] rest
    declare -p rest
  }

  run f 'string' 10 'with space'
  assert_output "declare -a rest=([0]=\"string\" [1]=\"10\" [2]=\"with space\")"
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
