import ../../type-core

class:Object() {
    methods
        Object::__getter__() {
            echo "[$__objectType__] $this"
        }

        Object::__setter__() {
            throw "[$__objectType__] is an immutable type."
        }

        Object::__type__() {
            echo "$__objectType__"
        }
    ~methods
}