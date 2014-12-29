class:Object() {

    if $instance
    then

        :

    else
        Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Object::__setter__() {
            oo:throw "[$__objectType__] is an immutable type."
        }

        Object::__type__() {
            echo "$__objectType__"
        }
    fi

} && oo:enableType

class:Var() {

    extends Object

    if $instance
    then

        :

    else

        Var::__getter__() {
            [ ! -z $this ] && echo "${__oo__storage[$this]}"
        }

        Var::__setter__() {
            [ ! -z $this ] && __oo__storage["$this"]="$1"
        }

    fi

} && oo:enableType

class:Array() {
    ## TODO: add for Array ##
    # http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

    ## TODO: implement indexing and converting to assoc
    # http://stackoverflow.com/a/14550606/595157

    extends Object

    if $instance
    then

        private:Var storedAsName

    else

        Array::__constructor__() {
            local storedAsName="__oo__array_${this//./_}"
            $this.storedAsName = "$storedAsName"
            oo:debug oo: creating array [ $storedAsName ]
            declare -ga "$storedAsName"
        }

        ## use the array like this: "${!Array}"
        Array::__getter__() {
            echo "$($this.storedAsName)[@]"
        }

        ## generates a list separated by new lines
        Array::List() {
            (
                IFS=$'\n'
                local indirectAccess="$($this.storedAsName)[*]"
                echo "${!indirectAccess}"
            )
        }

        Array::Contains() {
            local realArray="$($this)"
            local e
            for e in "${!realArray}"
                do [[ "$e" == "$1" ]] && return 0
            done
            return 1
        }

        Array::Add() {
            declare -ga "$($this.storedAsName)+=( \"\$@\" )"
        }

        Array::Merge() {
            $this.Add "$@"
        }
    fi
}

class:String() {

    extends Var

    if $instance
    then

        :

    else

        :

    fi

} && oo:enableType

class:Number() {

    extends Var

    if $instance
    then

        private:Var storedAsName

    else

        Number::__constructor__() {
            local storedAsName="__oo__number_${this//./_}"
            $this.storedAsName = "$storedAsName"
            oo:debug oo: creating number [ $storedAsName ]
            declare -gi "$storedAsName"
        }

        Number::__getter__() {
            local storedAsName=$($this.storedAsName)
            echo "${!storedAsName}"
        }

        Number::__setter__() {
            @mixed newValue
            @@verify "$@"

            local storedAsName=$($this.storedAsName)
            declare -gi "$storedAsName=$newValue"
        }

        Number::__increment__() {
            local storedAsName=$($this.storedAsName)
            declare -gi "$storedAsName+=1"
        }

    fi

} && oo:enableType

