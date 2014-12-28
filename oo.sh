#!/bin/bash

debug() {
    echo $@
}

oo:error() {
    echo ERROR: oo: $@
}

## oo functions ##
extends() {
    # we can only extend when there's what to extend...
    if [ ! -z $fullName ]; then
        local extensionType=$1; shift
    #    local realType=$objectType
    #    local objectType=$extensionType
        Type:$extensionType
        extending=true objectType=$extensionType oo:initialize \"\$@\"
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
    debug oo: initializing and constructing $fullName

    # alias for accessing the object
#    eval "$name(){ local this=$fullName; $objectType \"\$@\" }"
# TODO: setter

    # if not extending:
    [ -z $extending ] || debug oo: extending $fullName with $objectType...
    [ -z $extending ] && eval "
        $fullName() {
            local this=$fullName
            Type:$objectType::__getter__
        }
        "

    local methods=($(compgen -A function Type:$objectType::))

    debug oo: adding methods for type: $objectType

    if [ ! -z "${methods[*]}" ]; then
        for method in "${methods[@]}"; do

            debug "oo: mapping method: $fullName.${method##*::} ==> $method"

            # leave just function name from end
            method=${method##*::}


            # add method aliases
            eval "
                $fullName.$method() {
                    local this=$fullName
                    Type:$objectType::$method \"\$@\"
                }
                "
        done
    fi
    # foreach property
    #eval "$name.$property(){ local this=$fullName; $type::$method \"\$@\" }"
}

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

array:contains(){
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

declare -a importedTypes=()

oo:enableType(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function Type: | grep -v ::))
#    local allTypes=($(compgen -A function Type: | grep -v ::))
#    local types=($(array:substract allTypes importedTypes))

    if [ ${#types[@]} -eq 0 ]; then
        debug oo: no types to import... : ${types[@]}
    else
#        ${arrayZ[@]##t*e}
        #debug oo: parentName $fullName
        local type;
        for type in "${types[@]}"; do
            if ! array:contains "$type" "${importedTypes[@]}"; then
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
                    Type:$type
                    oo:initialize \"\$@\"
                }
                "
            fi
        done
    fi

#    debug oo: all types currently imported: "${types[@]}"
    importedTypes=("${types[@]}")
}

## add for Array ##
# http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

debug oo: starting bash-oo /infinity/ system

Type:Animal() {

    if $instance
    then

        printf ""

    else
        Type:Animal::__getter__() {
            echo "That is the animal"
        }
    fi

} && oo:enableType

Type:String() {
#    extends Object

    if $instance
    then

        Number phone

    else
        Type:String::__getter__() {
            echo "That is the string"
        }
    fi
} && oo:enableType

Type:Number() {
    printf ""
#    extends Object
} && oo:enableType

Type:Human() {
    extends Animal
#    extends immutable

    if $instance
    then

        Number height
        Number width
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

        Type:Human::__setter__() {
            echo "Human is immutable"
        }

#        Type:Human::__getter__() {
#            Type:Human::__toString__
#        }

    fi
} && oo:enableType

## usage ##
echo Creating Human Bazyli:
Human Bazyli
#Bazyli.height = 100
echo Eating:
Bazyli.eat strawberries
Bazyli.eat lemon
echo Who is he?
Bazyli
Bazyli.name
#Bazyli == Mark