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
            subject=level1 Log "creating array [ $_storedVariableName ]"
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
            # TODO: why global?
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
        # is var an array? {
        # [[ "$(declare -p $previousParamNo 2> /dev/null)" =~ "declare -a" ]]
        #

        Array::Serialize() {
            echo -n "["
            (
                local IFS=$'\UFFFFF'
                local indirectAccess="$($this._storedVariableName)[*]"
                local list="\"${!indirectAccess}\""
                local separator='", "'
                echo -n "${list/$'\UFFFFF'/$separator}"
            )
            echo -n "]"
        }

    ~methods

}