Type:Object() {

    if $instance
    then

        :

    else
        Type:Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Type:Object::__setter__() {
            oo:throw "[$__objectType__] is an immutable type."
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
    ## TODO: add for Array ##
    # http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

    ## TODO: implement indexing and converting to assoc
    # http://stackoverflow.com/a/14550606/595157

    extends Object

    if $instance
    then

        ~Var arrayName

    else

        Type:Array::__constructor__() {
            local arrayName="__oo__array_${this//./_}"
            $this.arrayName = "$arrayName"
            oo:debug oo: creating array [ $arrayName ]
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

    ## TODO: use declare -gi
    extends Var

} && oo:enableType

