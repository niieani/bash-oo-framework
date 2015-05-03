import ../../type-core
import Object

class:Var() {
    extends Object

    methods
        Var::__getter__() {
            [[ ! -z $this ]] && echo "${__oo__storage[$this]}"
        }

        Var::__setter__() {
            [[ ! -z $this ]] && __oo__storage["$this"]="$1"
        }
        
        Var::Equals() {
            [[ "$($this)" = "$1" ]]
            return $?
        }
    ~methods
}
