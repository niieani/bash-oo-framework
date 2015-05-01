import Var

class:Boolean() {
    extends Var

    methods
        Boolean::__setter__() {
            if [[ ! -z $this ]] && ([[ $this = "true" ]] || [[ $this = "false" ]])
            then
                __oo__storage["$this"]="$1"
            else
                throw "Invalid value"
            fi
        }
    ~methods
}
