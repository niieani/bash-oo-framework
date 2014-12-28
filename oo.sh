#!/bin/bash

debug() {
    echo $@
}

oo:error() {
    echo ERROR: oo: $@
}

declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects

#local -a __oo__importedTypes
#local -A __oo__storage

## oo functions ##
extends() {
    # we can only extend when there's what to extend...
    if [ ! -z $fullName ]; then
        local extensionType=$1; shift
    #    local realType=$objectType
    #    local objectType=$extensionType
        Type:$extensionType
        extending=true objectType=$extensionType oo:initialize "$@"
    fi
}

### REAL THING ###

oo:getFullName(){
    local thisName=$1
    local parentName=$fullName
    if [ -z "$parentName" ]; then
        echo $thisName;
    else
        echo $parentName.$thisName;
    fi
#    local parentObject=
}

oo:initialize(){
    [ -z $extending ] || debug "oo: basing $fullName (${FUNCNAME[2]}) on $objectType..."
    [ -z $extending ] && debug oo: initializing and constructing $fullName

    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
#    local visibleAsType=$objectType
#    [ -z $extending ] || {
#        visibleAsType="${FUNCNAME[2]}"
#        visibleAsType="${visibleAsType#*:}"
#    }

    local methods=($(compgen -A function Type:$objectType::))

    if [ ! -z "${methods[*]}" ]; then
        for method in "${methods[@]}"; do

            debug "oo: mapping method: $fullName.${method##*::} ==> $method"

            # leave just function name from end
            method=${method##*::}

            #local parentName=${fullName%.*}

            # add method aliases
            eval "
                $fullName.$method() {
                    local this=$fullName
                    local __objectType__=$visibleAsType
                    local __parentType__=$parentType
                    Type:$objectType::$method \"\$@\"
                }
                "
        done
    fi

    # alias for accessing the object
#    eval "$name(){ local this=$fullName; $objectType \"\$@\" }"
    # TODO: setter

    # if not extending:
    [ -z $extending ] && eval "
        $fullName() {
            local __objectType__=$objectType
            local __parentType__=$parentType

            # if no arguments, use the getter:
            [[ \$@ ]] || {
                $fullName.__getter__;
                return 0
            }
            local operator=\"\$1\"; shift
            if [ -z \"\$1\" ]; then
                case \"\$operator\" in
                    '++') $fullName.__increment__ \"\$@\" ;;
                    '--') $fullName.__decrement__ \"\$@\" ;;
                    *)  oo:error no value given
                        return 1 ;;
                esac
            else
                case \"\$operator\" in
                    '=') $fullName.__setter__ \"\$@\" ;;
                    '==') $fullName.__equals__ \"\$@\" ;;
                    '+') $fullName.__add__ \"\$@\" ;;
                    '-') $fullName.__substract__ \"\$@\" ;;
                    '*') $fullName.__multiply__ \"\$@\" ;;
                    '/') $fullName.__divide__ \"\$@\" ;;
                esac
            fi
        }
        "

    # first run with the arguments given only when an operator is in use
    if [ ! -z $1 ]; then
        if [ $1 = '~' ]; then
            $fullName.__constructor__ "$@"
        else
            $fullName "$@"
        fi
    fi

    # foreach property
    #eval "$name.$property(){ local this=$fullName; $type::$method \"\$@\" }"
}

array:contains(){
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

oo:enableType(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function Type: | grep -v ::))
#    local allTypes=($(compgen -A function Type: | grep -v ::))
#    local types=($(array:substract allTypes __oo__importedTypes))

    if [ ${#types[@]} -eq 0 ]; then
        debug oo: no types to import... : ${types[@]}
    else
#        ${arrayZ[@]##t*e}
        #debug oo: parentName $fullName
        local type;
        for type in "${types[@]}"; do
            if ! array:contains "$type" "${__oo__importedTypes[@]}"; then
                debug oo: enabling type [ $type ]

                # trim Type: from front
                type=${type#*:}

                # import methods
                instance=false Type:$type

                # 'new' function for creating the object
                eval "
                $type() {
                    local parentType=\${FUNCNAME[1]}
                    parentType=\${parentType#*:}
                    local objectType=$type

                    if [ \$parentType = \$objectType ]; then
                        oo:error recurrent nesting types within itself is not possible
                        return 1
                    fi

                    local parentName=\$fullName
                    debug oo: new object $type, parent: \$fullName
                    local fullName=\$(oo:getFullName \$1)
                    shift

                    __oo__objects[\"\$fullName\"]=\$objectType

                    Type:$type
                    oo:initialize \"\$@\"
                }
                "
            fi
        done
    fi

#    debug oo: all types currently imported: "${types[@]}"
    __oo__importedTypes=("${types[@]}")
}

## add for Array ##
# http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

debug oo: starting bash-oo /infinity/ system

Type:Object() {

    if $instance
    then

        printf ""

    else
        Type:Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Type:Object::__setter__() {
            echo "[$__objectType__] is an immutable type"
        }
    fi

} && oo:enableType

Type:Var() {

    extends Object

    if $instance
    then

        printf ""

    else

        Type:Var::__getter__() {
            [ ! -z $this ] && echo "${__oo__storage[$this]}"
        }
        Type:Var::__setter__() {
            [ ! -z $this ] && __oo__storage["$this"]="$1"
        }

    fi

} && oo:enableType

Type:String() {

    extends Var

    if $instance
    then

        printf ""

    else

        printf ""

    fi

} && oo:enableType

Type:Number() {

    extends Var

} && oo:enableType


Type:Animal() {

    extends Object

    if $instance
    then

        printf ""

    else
        Type:Animal::__getter__() {
            echo "That is the animal"
        }
    fi

} && oo:enableType

Type:Human() {

    extends Animal

    if $instance
    then

        Number height
        Number width
        Number phone
        String name

    else

        Type:Human::eat() {
            echo "$this is eating $1"
        }

        Type:Human::__equals__() {
            echo "Checking if $this equals $1"
        }

        Type:Human::__toString__() {
            echo "I'm a human ($this)"
        }

        Type:Human::__getter__() {
            $this.__toString__
        }

        Type:Human::__constructor__() {
            echo "Hello, I am the constructor! You have passed these arguments: " "$@"
        }

    fi
} && oo:enableType

## usage ##
echo Creating Human Bazyli:
Human Bazyli
# if you want to use a constructor, create an object and use the tilda ~ operator
#Human Mambo ~ Bazyli Brzoska 150 960
#Bazyli.height = 100
echo Eating:
Bazyli.eat strawberries
Bazyli.eat lemon
echo Who is he?
Bazyli
# empty
Bazyli.name
# set value
Bazyli.name = "Bazyli Brzóska"
# set height
Bazyli.height = 170

echo $(Bazyli.name) is $(Bazyli.height) cm tall.

Bazyli = "house"
#Bazyli == Mark








############

# TODO: something is wrong with this:
array:substract(){
    declare -a argAry1=("${!1}")
    declare -a argAry2=("${!2}")
    __output_array_temp__=()

    for i in "${argAry1[@]}"; do
        skip=
        for j in "${argAry2[@]}"; do
            [[ $i == $j ]] && { skip=1; break; }
        done
        [[ -n $skip ]] || __output_array_temp__+=("$i")
    done
    printf -- '%s\n' "${__output_array_temp__[@]}"
#    echo "${__output_array_temp__[@]}"
#    declare -p __output_array_temp__
}