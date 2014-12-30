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

        private:Var _storedVariableName

    else

        Array::__constructor__() {
            local _storedVariableName="__oo__array_${this//./_}"
            $this._storedVariableName = "$_storedVariableName"
            oo:debug oo: creating array [ $_storedVariableName ]
            declare -ga "$_storedVariableName"
        }

        ## use the array like this: "${!Array}"
        Array::__getter__() {
            echo "$($this._storedVariableName)[@]"
        }

        ## generates a list separated by new lines
        Array::List() {
            (
                IFS=$'\n'
                local indirectAccess="$($this._storedVariableName)[*]"
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
            declare -ga "$($this._storedVariableName)+=( \"\$@\" )"
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

        private:Var _storedVariableName

    else

        Number::__constructor__() {
            local _storedVariableName="__oo__number_${this//./_}"
            $this._storedVariableName = "$_storedVariableName"
            oo:debug oo: creating number [ $_storedVariableName ]
            declare -gi "$_storedVariableName"
        }

        Number::__getter__() {
            local _storedVariableName=$($this._storedVariableName)
            echo "${!_storedVariableName}"
        }

        Number::__setter__() {
            @mixed newValue
            @@verify "$@"

            local _storedVariableName=$($this._storedVariableName)
            declare -gi "$_storedVariableName=$newValue"
        }

        Number::__increment__() {
            local _storedVariableName=$($this._storedVariableName)
            declare -gi "$_storedVariableName+=1"
        }

    fi

} && oo:enableType

