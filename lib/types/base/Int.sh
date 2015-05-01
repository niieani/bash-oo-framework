import Var

class:Number() {

    extends Var

    private Var _storedVariableName

    methods
        Number::__constructor__() {
            local _storedVariableName="__oo__number_${this//./_}"
            $this._storedVariableName = "$_storedVariableName"
            Log.Debug oo: creating number [ $_storedVariableName ]
            declare -gi "$_storedVariableName"
        }

        Number::__getter__() {
            local _storedVariableName=$($this._storedVariableName)
            echo "${!_storedVariableName}"
        }

        Number::__setter__() {
            @mixed newValue
            @@verify
            Log.Debug "Var: $($this._storedVariableName), New Value: ${newValue}"

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

}
