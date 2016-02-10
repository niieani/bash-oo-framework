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

} && Type.Load

class:Human() {

    extends Animal

    public Number height
    public Number width
    public Number phone
    public String name

    methods

        Human::__toString__() {
            echo "I'm a human ($this)"
        }

        Human::__getter__() {
            $this.__toString__
        }

        Human::Eat() {
            echo "$this is eating $1"
        }

        Human::Example() {
            ## TODO: this shouldn't need eval, but for the strangest reason ever, it does.
            ## also: subshell protects variables from falling through to another overload
            ## perhaps we could use it here?

            : @Array      mergeWith
            : @Number     many
            : [...rest]     stuff

            @@map && {
                echo Testing \"$mergeWith\" at manyCount: $many
                echo Stuff: "${stuff[*]}"
                return
            }


            ## here we have an overloaded version of this function that takes in Array, Object and params
            ## beauty is that by passing different objects we can get
            : @Array      mergeWith
            : @Object     overloadedType

            @@map && {
                echo Merging \"$mergeWith\", we use the Object: $overloadedType
                return
            }

        }

        Human::__equals__() {
            echo "TODO: Checking if $this equals $1"
        }


        Human::__constructor__() {
            subject=level1 Log "Hello, I am the constructor! You have passed these arguments [ $@ ]"
        }

    ~methods

} && Type.Load

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

} && Type.Load

class:BaseTestBase() {

    extends Var

    method BaseTestBase::__setter__() {
        echo "I am the setter of the BaseTestBase"
        Var::__setter__ "$@"
    }

} && Type.Load

class:ExtensionTest() {

    extends BaseTestBase

    method ExtensionTest::__setter__() {
        echo "That is just the test showing that I can call the base method"
        BaseTestBase::__setter__ "$@"
    }

} && Type.Load

static:Color() {
    extends Object

    String Default = $'\033[0m'
    String White = $'\033[0;37m'
    String Black = $'\033[0;30m'
    String Blue = $'\033[0;34m'

} && Type.Load
