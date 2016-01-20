import Var

class:Boolean() {
    extends Var

    methods
        Boolean::__getter__() {
            test ${__oo__storage["$this"]} = true
            return $?
        }
        Boolean::__setter__() {
            if [[ ! -z $1 ]] && ([[ $1 = "true" ]] || [[ $1 = "false" ]])
            then
                __oo__storage["$this"]="$1"
            else
                throw "Invalid value"
            fi
        }
    ~methods
}
