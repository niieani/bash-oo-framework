class:Object() {

    methods
        Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Object::__setter__() {
            oo:throw "[$__objectType__] is an immutable type."
        }

        Object::__type__() {
            echo "$__objectType__"
        }
    ~methods

} && oo:enableType

class:Var() {

    extends Object

    methods
        Var::__getter__() {
            [ ! -z $this ] && echo "${__oo__storage[$this]}"
        }

        Var::__setter__() {
            [ ! -z $this ] && __oo__storage["$this"]="$1"
        }
    ~methods

} && oo:enableType

class:Const() {
    extends Var

    method Const::__constructor__() {
        [[ $1 = '=' ]] && shift
        Var::__setter__ "$@"
    }

    # TODO [cannot use setter when creating the object]
    #method Const::__setter__() {
    #    oo:throw "$this is immutable"
    #}
} && oo:enableType

class:Boolean() {
    extends Var
    
    methods
        Boolean::__setter__() {
            if [ ! -z $this ] && ([ $this = "true" ] || [ $this = "false" ])
            then
                __oo__storage["$this"]="$1"
            else
                oo:throw "Invalid value"
            fi 
        }
    ~methods
} && oo:enableType

class:Array() {
    ## TODO: add for Array ##
    # http://brizzled.clapper.org/blog/2011/10/28/a-bash-stack/

    ## TODO: implement indexing and converting to assoc
    # http://stackoverflow.com/a/14550606/595157

    extends Object

    private Var _storedVariableName

    methods
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
    ~methods

} && oo:enableType

class:String() {
    extends Var

    static String.GetSanitizedVariableName() {
        @mixed input
        @@verify "$@"

        local clean="${input//[^a-zA-Z0-9]/_}"
        echo "${clean^^}"
    }

    static String.TabsForSpaces() {
        @mixed input
        # TODO: @mixed spaceCount=4
        @@verify "$@"

        # hardcoded 1 tab = 4 spaces
        echo "${input//[	]/    }"
    }

    static String.RegexMatch() {
        @mixed text; @mixed regex; @mixed param
        @@verify "$@"

        if [[ "$text" =~ $regex ]]; then
            if [[ ! -z $param ]]; then
                echo "${BASH_REMATCH[${param}]}"
            fi
            return 0
        else
            return 1
            # no match
        fi
    }

    static String.SpaceCount() {
        @mixed text
        @@verify "$@"

        # note: you shouldn't mix tabs and spaces, we explicitly don't count tabs here
        local spaces="$(String.RegexMatch "$text" "^[	]*([ ]*)[.]*" 1)"
        echo "${#spaces}"
    }

    static String.Trim() {
        @mixed text
        @@verify "$@"

        echo "$(String.RegexMatch "$text" "^[ 	]*(.*)" 1)"
    }

    static String.GetXSpaces() {
        @mixed howMany
        @@verify "$@"
        
        [[ "$howMany" -gt 0 ]] && ( printf "%*s" "$howMany" )
    }
    
    method String::GetSanitizedVariableName() {
        String.GetSanitizedVariableName "$($this)"
    }

    method String::RegexMatch() {
        @mixed regex; @mixed param
        @@verify "$@"

        String.RegexMatch "$($this)" "$regex" "$param"
    }

} && oo:enableType

class:ImmutableString() {
    extends String

    method ImmutableString::__constructor__() {
        #[ $1 = '=' ] && shift
        Var::__setter__ "$@"
    }

    method ImmutableString::__setter__() {
        oo:throw "$this is immutable"
    }
} && oo:enableType

class:Number() {

    extends Var

    private Var _storedVariableName

    methods
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
            @@verify
            #echo "NEW VALUE: _${newValue}_"
            
            local _storedVariableName=$($this._storedVariableName)
            declare -gi "$_storedVariableName=$newValue"
        }

        Number::__increment__() {
            local _storedVariableName=$($this._storedVariableName)
            declare -gi "$_storedVariableName+=1"
        }

        Number::__decrement__() {
            local _storedVariableName=$($this._storedVariableName)
            declare -gi "$_storedVariableName+=-1"
        }

        Number::__add__() {
            @mixed value
            @@verify
            
            expr $($this) + $value
            #local _storedVariableName=$($this._storedVariableName)
            #echo $_storedVariableName+=$value
            #declare -gi "$_storedVariableName+=$value"
        }

        Number::__subtract__() {
            @mixed value
            @@verify
            
            expr $($this) - $value
            #local _storedVariableName=$($this._storedVariableName)
            #declare -gi "$_storedVariableName=$(expr $this - $value)"
        }

        Number::__multiply__() {
            @mixed value
            @@verify
            
            expr $($this) \* $value
        }

        Number::__divide__() {
            @mixed value
            @@verify
            
            expr $($this) / $value
            #local _storedVariableName=$($this._storedVariableName)
            #declare -gi "$_storedVariableName/=$value"
        }
    ~methods

} && oo:enableType
