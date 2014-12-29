Type:Test() {

    if $instance
    then

        :

    else

        Type:Test::__getter__() {
            echo "[$__objectType__] $this"
        }

    fi

} && oo:enableType
