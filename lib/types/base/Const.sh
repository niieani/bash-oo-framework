import Var

class:Const() {
    extends Var

    method Const::__constructor__() {
        [[ $1 = '=' ]] && shift
        Var::__setter__ "$@"
    }

    # TODO [cannot use setter when creating the object]
    #method Const::__setter__() {
    #    throw "$this is immutable"
    #}
}