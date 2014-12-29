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

        Type:Human::example() {
            ## TODO: this shouldn't need eval, but for the strangest reason ever, it does.
            ## also: subshell protects variables from falling through to another overload
            ## perhaps we could use it here?

            eval @Array      mergeWith
            eval @Number     many
            eval @params     stuff

            @@verify "$@" && {
                echo Testing \"$mergeWith\" at manyCount: $many
                echo Stuff: "${stuff[*]}"
                return
            }


            ## here we have an overloaded version of this function that takes in Array, Object and params
            ## beauty is that by passing different objects we can get
            eval @Array      mergeWith
            eval @Object     overloadedType

            @@verify "$@" && {
                echo Merging \"$mergeWith\", we use the Object: $overloadedType
                return
            }

        }

        Type:Human::__equals__() {
            echo "TODO: Checking if $this equals $1"
        }

        Type:Human::__toString__() {
            echo "I'm a human ($this)"
        }

        Type:Human::__getter__() {
            $this.__toString__
        }

        Type:Human::__constructor__() {
            oo:debug "Hello, I am the constructor! You have passed these arguments [ $@ ]"
        }

    fi
} && oo:enableType

Static:Singleton() {

    extends Var

    Type:Singleton::__constructor__() {
        echo "Yo Yo. I'm a singleton. Meaning. Static. Yo."
    }

} && oo:enableType