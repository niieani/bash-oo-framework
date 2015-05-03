import Var

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
            Log.Debug 1 "creating array [ $_storedVariableName ]"
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

        Array::LastElement() {
            local realArray="$($this)"
            echo "${realArray[(${#realArray[@]}-1)]}"
            # alternative in bash 4.2: ${realArray[-1]}
        }

        Array::WithoutLastElement() {
            local realArray="$($this)"
            echo "${realArray[@]:0:(${#realArray[@]}-1)}"
        }
    ~methods

}