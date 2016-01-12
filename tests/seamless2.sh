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

getDefinition() {
  ## TODO: fix escaping '
  local variableName="$1"
  
  # local regex='declare -([a-z-A-Z-]+) [a-zA-Z_][a-zA-Z0-9_]*=(.*)'
  # local regex='declare -[a-z-A-Z-]+ arr=(.*)'
  local regexArray="declare -([a-zA-Z-]+) $variableName='(.*)'"
  local regex="declare -([a-zA-Z-]+) $variableName=\"(.*)\""
  local definition=$(declare -p $variableName)
  
  local escaped="'\\\'"
  
  if [[ "$definition" =~ $regexArray ]]
  then
    echo "${BASH_REMATCH[2]//$escaped/}"
  elif [[ "$definition" =~ $regex ]]
  then
    echo "${BASH_REMATCH[2]//$escaped/}"
  fi
  
  __declaration_type=${BASH_REMATCH[1]}
}

# shopt -s lastpipe # not needed
shopt -s expand_aliases
declare __declaration_type

Console.WriteStdErr() {
    # http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
    cat <<< "$*" 1>&2
    return 0
}

capturePipe() {
  read -r -d '' $1
}

capturePipeFaithful() {
  IFS= read -r -d '' $1
}

## note: declaration needs to be trimmed, 
## since bash adds an enter at the end, hence %?
alias @resolveThis="
  local declaration;
  if [ -z \${this+x} ]; 
  then
    capturePipe declaration; 
    local -\${__declaration_type:--} this=\${declaration}; # %?
  else
    declaration=\$(getDefinition \$this); 
    unset this;
    local -\${__declaration_type:--} this=\${declaration};
  fi;"

alias @return='getDefinition'

map.set() {
  @resolveThis
  
  this["$1"]="$2"
  
  @return this
}

map.delete() {
  @resolveThis
  
  # local declaration
  # IFS= read -r -d '' declaration
  # local -A this=${declaration%?}
  
  unset this["$1"]
  
  @return this
}

map.get() {
  
  @resolveThis
  
  # local declaration
  # IFS= read -r -d '' declaration
  # local -A this=${declaration%?}

  # declare -p this
  local value="${this[$1]}"
  @return value
}


declare -A oldarr=([' escape "1" me ']="me \" too" ["simple"]="123" ["simple'2"]="99'9")

echo
echo copying arrays:
# getDefinition oldarr
declare -A cpyarr=$(getDefinition oldarr)
declare -p oldarr
declare -p cpyarr
echo

# declare -A addRemArr=$(getDefinition oldarr | 
#   map.set "info 123  \"hey" "works  yo" |
#   map.delete "simple")

declare -A simple=()

# declare -A addRemArr=$(getDefinition simple | 
# declare -A withEnters=$()

echo
echo copy empty:
  getDefinition simple
echo

echo
echo simple addition:
  getDefinition simple | 
  map.set "simple" "simple"
echo

echo
echo with enters:
  getDefinition simple | 
  map.set "enter" "$(printf "a\nb\nc")"
echo

echo
echo adding after enters:
  getDefinition simple | 
  map.set "enter" "$(printf "a\nb\nc")" |
  map.set "space" "1 space  2" |
  map.set "another" "$(printf "q\nb\nr")"
echo

echo
echo deleting:
  getDefinition simple | 
  map.set "test" "1234" |
  map.set "enter" "$(printf "a\nb\nc")" |
  map.delete "enter"
echo

echo
echo adding and getting:
  getDefinition oldarr | 
  map.set "sober" "works  yo" |
  map.get "sober"
echo

something=$(this=oldarr map.get "simple")
echo $something

# declare -A newOne=$(getDefinition oldarr | map.set "info 123  \"hey" "works  yo")
# declare -p newOne

# array.getDefinition arr
# eval "$return"
# declare -p wtf

# echo "hello world" | read test; echo test=$test | read test2; echo test2=$test2

# declare x="hi world"
# @ x | string.toUpper

# ret=$(echo "hi world" | string.length)
# echo $return