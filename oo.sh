#!/bin/bash

debug() {
    echo $@
}

oo:error() {
    echo ERROR: oo: $@
}

shopt -s expand_aliases
declare -a __oo__importedTypes
declare -A __oo__storage
declare -A __oo__objects
declare -A __oo__objects_private

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

oo:assignParamsToLocal() {
    ## unset first miss
    unset __oo__params[0]
    declare -i i
    local iparam
    local variable
    local type
    for i in "${!__oo__params[@]}"
    do
#        debug "i    : $i"

        iparam=$i

        variable="${__oo__params[$i]}"
#        debug "var  : ${__oo__params[$i]}"

        i+=-1
        type="${__oo__param_types[$i]}"
#        debug "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct
        # test if the types are right, if not, add note and "read" to wait for user input
        # assign correct values approprietly so they are avail later on

        if [ $type = 'params' ]; then
            for _x in "${!__oo__params[@]}"
            do
                #debug oo: we are params so we shift
                [ "${__oo__param_types[$_x]}" != 'params' ] && eval shift
            done
            eval "$variable=\"\$@\""
#            $variable="$@"
            return
        else
            ## assign value ##

    #        debug "value: ${!iparam}"
    #        eval "$variable=\"${!iparam}\""
            eval "$variable=\"\$$iparam\""
        fi
    done
}

alias oo:stashPreviousLocal="declare -a \"__oo__params+=( \$_ )\""
alias @@verify="oo:stashPreviousLocal; oo:assignParamsToLocal " # ; for i in \${!__oo__params[@]}; do
alias @params="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "

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

oo:isMethodDeclared() {
    local fullMethodName="$1"
    local compgenOutput=($(compgen -A function $fullMethodName))
    [[ ${#compgenOutput[@]} -gt 0 ]] && return 0
    return 1
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

            #debug \"oo: CALL STACK: \${FUNCNAME[@]}\"
#            array:contains __oo__objects_private \"${__oo__objects_private[@]}\" || {
#                parentType=\${FUNCNAME[2]}
#                [[ \${parentType%%:*} = 'Type' ]] && {
#                    oo:error cannot access private type
#                    return 1
#                }
#            }

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
        if [ $1 = '~~' ]; then
            shift
            oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__ "$@"
        else
            # we are immediately doing an operation, so use the default constructor and run the thing!
            oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__
            $fullName "$@"
        fi
    else
        # just run the constructor if any
        oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__
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
                    [[ ! -z \$__private__ ]] && parentType=\${FUNCNAME[2]}
                    parentType=\${parentType#*:}
                    local objectType=$type

                    if [ \$parentType = \$objectType ]; then
                        oo:error recurrent nesting types within itself is not possible
                        return 1
                    fi

                    local parentName=\$fullName
                    local fullName=\$(oo:getFullName \$1)
                    shift

                    __oo__objects[\"\$fullName\"]=\$objectType

                    if [[ -z \$__private__ ]]; then
                        debug oo: new object $type, parent: \$parentName
                    else
                        debug oo: new private object $type, parent: \$parentName
                        __oo__objects_private[\"\$fullName\"]=\$objectType
                    fi

                    Type:$type
                    oo:initialize \"\$@\"
                }

                # TODO: if private, don't allow public access
                ## private definition ##
                ~$type() {
                    __private__=true $type \"\$@\"
                }

                ## for defining parameters ##
#                alias @$type=\"declare -a \\\"params+=( $type )\\\"; local\"
                "
                alias @$type="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( $type )\"; local "

#                local mimikpart="Mimi"
#
#                local mimik=${mimikpart}A
#                echo \'$mimik\'
#                alias $mimik='echo DOING MIMI'
#                alias $mimik
#
#                local newAlias=${type}A
#                echo \'$newAlias\'
#                alias $newAlias='echo DOING MIMI'
#                alias $newAlias

#                alias @$type='declare -a "params+=( $type )"; local'
#                alias @$type
            fi
        done
    fi

#    debug oo: all types currently imported: "${types[@]}"
    __oo__importedTypes=("${types[@]}")
}

## add for Array ##
# http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

debug oo: starting bash-oo /infinity/ system
#alias mimi='echo umpa'

Type:Object() {

    if $instance
    then

        :

    else
        Type:Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Type:Object::__setter__() {
            debug "[$__objectType__] is an immutable type."
        }

        Type:Object::__type__() {
            echo "$__objectType__"
        }
    fi

} && oo:enableType

Type:Var() {

    extends Object

    if $instance
    then

        :

    else

        Type:Var::__getter__() {
            [ ! -z $this ] && echo "${__oo__storage[$this]}"
        }
        Type:Var::__setter__() {
            [ ! -z $this ] && __oo__storage["$this"]="$1"
        }

    fi

} && oo:enableType

Type:Array() {

    extends Object

    if $instance
    then

        ~Var arrayName

    else

        Type:Array::__constructor__() {
            local arrayName="__oo__array_${this//./_}"
            $this.arrayName = "$arrayName"
            debug oo: creating array [ $arrayName ]
            declare -ga "$arrayName"
        }

        ## use the array like this: "${!Array}"
        Type:Array::__getter__() {
            echo "$($this.arrayName)[@]"
        }

        ## generates a list separated by new lines
        Type:Array::list() {
            (
                IFS=$'\n'
                local indirectAccess="$($this.arrayName)[*]"
                echo "${!indirectAccess}"
            )
        }

        Type:Array::contains() {
            local realArray="$($this)"
            local e
            for e in "${!realArray}"; do [[ "$e" == "$1" ]] && return 0; done
            return 1
        }

        Type:Array::add() {
            declare -ga "$($this.arrayName)+=( \"\$@\" )"
        }

        Type:Array::merge() {
            $this.add "$@"
        }

        Type:Array::example() {
            ## TODO: this shouldn't need eval, but for the strangest reason ever, it does
            eval @Array      mergeWith
            eval @Number     many
            eval @params     stuff

            @@verify "$@" && {
                echo Merging \"$mergeWith\" at manyCount: $many
                echo Stuff: "${stuff[*]}"
                return
            }

            ## here we have an overloaded version of this function that takes in Array, Object and params
            ## beauty is that by passing different objects we can get
            eval @Array      mergeWith
            eval @Object     overloadedType
            eval @params     stuff

            @@verify "$@" && {
                echo Merging \"$mergeWith\", we use the Object: $overloadedType
                echo Stuff: "${stuff[*]}"
                return
            }
        }
    fi
}

Type:String() {

    extends Var

    if $instance
    then

        :

    else

        Type:String::__setter__() {
            $this.doTheBoogy "$1"
        }

        Type:String::doTheBoogy() {
            [ ! -z $this ] && __oo__storage["$this"]="$1"
        }

    fi

} && oo:enableType

Type:Number() {

    extends Var

} && oo:enableType


Type:Animal() {

    extends Object

    if $instance
    then

        :

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
            debug "Hello, I am the constructor! You have passed these arguments [ $@ ]"
        }

    fi
} && oo:enableType

## usage ##
echo Creating Human Bazyli:
Human Bazyli
# if you want to use a constructor, create an object and use the double tilda ~~ operator
Human Mambo ~~ Mambo Jumbo 150 960
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

# throws an error
Bazyli = "house"

Array Letters
Array Letters2

Letters.add "Hello Jean" "Hello Maria"
Letters.add "Hello Bobby"
Letters2.add "Hello Frank" "Bomba"
Letters2.add "Dude,
              How are you doing?"

letters2=$(Letters2)
Letters.add "${!letters2}"
#Letters.merge "yes" "true"


letters=$(Letters)
for letter in "${!letters}"; do
    echo ----
    echo "$letter"
done

## or simply:
#Letters.list

Letters.contains "Hello" && echo "This shouldn't happen"
Letters.contains "Hello Bobby" && echo "Bobby was welcomed"
Letters.example "one single sentence" two "and here" "we put" "some stuff"


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