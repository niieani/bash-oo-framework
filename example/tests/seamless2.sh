#!/usr/bin/env bash

# It will make more sense to not use . to invoke methods
# how about we use first param as method?
#  
# array something
# ~ something push 'abc'
# something print
#
# string koko='123ha'
# koko=$(koko sanitize)
# 
# koko toUpper 
# equivalent of: string.toUpper $ref:koko
# equivalent of (?): string.toUpper < <(koko)
# koko=$(koko | string.toUpper | string.normalize)
#
# koko # returns $ref:koko
# typeof koko # returns 'string'
#
# there could be intelligent assignment, because:
# a pure invocation of an instance (variable) could set the _TYPE=string 
# which could be used for matching later on in the pipes
# ...as long as that's not a problem with subshells... 
# plus, we even don't need to use values passed in from the pipe in the methods 
# since the invocation can set a RETURNS=... variable instead
#
# so theoretically we could:
#
# string kokoNormalized=$(koko |~ toUpper |~ normalize)
#
# tildas would be necessary (?) since the invocations would come from command_not_found... 
# 
# koko toUpper | string.sanitize
# string.toUpper $koko 
#
#
# pass around arrays as stringified definitions
# so that we always work on a new copy
# in fact, the return (echo) value should be the assignment, like:
# (a b c "d e" f)
# or
# ([ab]="12" [cd]="34")
# so then we can simply:
# someArr=$(firstArr | forEach toUpper | forEach toLower)

# string.length() {
#   read this
# 	return=${#this}
#   echo "$return"
# }

# string.toUpper() {
#   read this
# 	return="${this^^}"
#   echo "$return"
# }

# something(){ 
#   eval echo \$$FUNCNAME
# }

# something

Variable::ExportDeclarationAndTypeToVariables() {
  local variableName="$1"
  local targetVariable="$2"
  
  local declaration
  local regexArray="declare -([a-zA-Z-]+) $variableName='(.*)'"
  local regex="declare -([a-zA-Z-]+) $variableName=\"(.*)\""
  local definition=$(declare -p $variableName)
  
  local escaped="'\\\'"
  
  if [[ "$definition" =~ $regexArray ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}"
  elif [[ "$definition" =~ $regex ]]
  then
    declaration="${BASH_REMATCH[2]//$escaped/}"
  fi
  
  eval $targetVariable=\$declaration
  eval ${targetVariable}_type=\${BASH_REMATCH[1]}
  # __declaration_type=${BASH_REMATCH[1]}
}

Variable::PrintDeclaration() {
  local __declaration
  Variable::ExportDeclarationAndTypeToVariables "$1" __declaration
  echo "$__declaration"
}


# shopt -s lastpipe # not needed
shopt -s expand_aliases
declare __declaration_type

Console::WriteStdErr() {
    # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
    cat <<< "$*" 1>&2
    return 0
}

Pipe::Capture() {
  read -r -d '' $1
}

Pipe::CaptureFaithful() {
  IFS= read -r -d '' $1
}

## note: declaration needs to be trimmed, 
## since bash adds an enter at the end, hence %?
alias @resolveThis="
  local __declaration;
  if [ -z \${this+x} ]; 
  then
    Pipe::Capture __declaration;
  else
    Variable::ExportDeclarationAndTypeToVariables \$this __declaration;
    unset this;
  fi;
  local -\${__declaration_type:--} this=\${__declaration};"

alias @return='Variable::PrintDeclaration'
alias @get='Variable::PrintDeclaration'

map.set() {
  @resolveThis
  
  this["$1"]="$2"
  
  @return this
}

map.delete() {
  @resolveThis
  
  unset this["$1"]
  
  @return this
}

map.get() {
  @resolveThis

  local value="${this[$1]}"
  @return value
}


declare -A oldarr=([' escape "1" me ']="me \" too" ["simple"]="123" ["simple'2"]="99'9")

echo
echo copying arrays:
# Variable::PrintDeclaration oldarr
declare -A cpyarr=$(Variable::PrintDeclaration oldarr)
declare -p oldarr
declare -p cpyarr
echo


echo
echo nesting arrays:
declare -A nstarr=([first]=123 [nested]=$(Variable::PrintDeclaration oldarr))
# Variable::PrintDeclaration nstarr
declare -A nstarr=${nstarr[nested]}
declare -p nstarr
echo
# Variable::PrintDeclaration outOfArr


# declare -A addRemArr=$(Variable::PrintDeclaration oldarr |
#   map.set "info 123  \"hey" "works  yo" |
#   map.delete "simple")

declare -A simple=()

# declare -A addRemArr=$(Variable::PrintDeclaration simple |
# declare -A withEnters=$()



echo
echo copy empty:
  Variable::PrintDeclaration simple
echo

echo
echo simple addition:
  Variable::PrintDeclaration simple |
  map.set "simple" "simple"
echo

echo
echo with enters:
  Variable::PrintDeclaration simple |
  map.set "enter" "$(printf "a\nb\nc")"
echo

echo
echo adding after enters:
  Variable::PrintDeclaration simple |
  map.set "enter" "$(printf "a\nb\nc")" |
  map.set "space" "1 space  2" |
  map.set "another" "$(printf "q\nb\nr")"
echo

echo
echo deleting:
  Variable::PrintDeclaration simple |
  map.set "test" "1234" |
  map.set "enter" "$(printf "a\nb\nc")" |
  map.delete "enter"
echo

echo
echo adding and getting:
  Variable::PrintDeclaration oldarr |
  map.set "sober" "works  yo" |
  map.get "sober"
echo

something=$(this=oldarr map.get "simple")
echo $something

# someMap | .set one 'val' | .set two 'val' | .get one | .toUpper | .sanitize | .parseInt

# obj=$(new Object)

# arr=$(Array.FromFile open.txt $delimiter)
# arr=$(Array.FromDir ./)
# arr | .forEach element 'echo "$element"'
# arr | .filter element "element | .startsWith 'ab'"

# arr filter ( element "element startsWith ( 'ab' )" )
#     without ( 'rambo' )

# object updateProperty ( 1 2 )
# human .leftLeg assign 

#  when invoking via the autogenerated function
# arr forEach element 'echo "$element"'

# autogenerated function should be generic, i.e. so that it will always find out
# the current type of the underlying var, since it can vary based on scope

# Object someTest=$(new Test 'Primavera')
# someTest=$(someTest | .startTimer)
# this=someTest Test.startTimer
# Test.startTimer $ref:someTest

# someTest .startTimer
# someTest .timer .start

# for objects we could capture the name during declaration (special declaration trap)
# and then we create a function with the same name to handle execution and declaration printing
# perhaps instead of declaration printing we set this= prior to invocation
#
# for each method of each type we create universal functions .function that 
# runs / selects the right vesion to run based on the type passed in

# this way we can have .contains for both arrays and strings and custom objects

# properties of custom objects should always be stored 'serialized', i.e. as declarations
# this way we can nest them indefinitely