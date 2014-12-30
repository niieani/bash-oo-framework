class:Animal() {

    extends Object

    if $instance
    then

        :

    else
        Animal::__getter__() {
            echo "That is the animal"
        }
    fi

} && oo:enableType

class:Human() {

    extends Animal

    if $instance
    then

        Number height
        Number width
        Number phone
        String name

    else

        Human::Eat() {
            echo "$this is eating $1"
        }

        Human::Example() {
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

        Human::__equals__() {
            echo "TODO: Checking if $this equals $1"
        }

        Human::__toString__() {
            echo "I'm a human ($this)"
        }

        Human::__getter__() {
            $this.__toString__
        }

        Human::__constructor__() {
            oo:debug "Hello, I am the constructor! You have passed these arguments [ $@ ]"
        }

    fi
} && oo:enableType

static:Singleton() {

    extends Var

    Number YoMamaNumber = 150

    Singleton::__constructor__() {
        echo "Yo Yo. I'm a singleton. Meaning. Static. Yo."
        Singleton = "Yo Mama!"
    }

    Singleton.PrintYoMama() {
        ## prints the stored value, which is set in the constructor above
        echo "$(Singleton) $(Singleton.YoMamaNumber)!"
    }

} && oo:enableType

class:BaseTestBase() {

    extends Var

    if $instance
    then

        :

    else
        BaseTestBase::__setter__() {
            echo "I am the setter of the BaseTestBase"
            Var::__setter__ "$@"
        }
    fi

} && oo:enableType

class:ExtensionTest() {

    extends BaseTestBase

    if $instance
    then

        :

    else
        ExtensionTest::__setter__() {
            echo "That is just the test that I can call the base constructor"
            BaseTestBase::__setter__ "$@"
        }
    fi

} && oo:enableType