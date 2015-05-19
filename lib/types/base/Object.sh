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

        Object::Equals() {
            $this.__equals__ "$@"
        }

        Object::Serialize() {
            local objectName

            local -a nestedObject
            local -i nestedCount=0

            for objectName in "${!__oo__objects[@]}"
            do
                if [[ -z "${__oo__objects_private[$objectName]}" && "$objectName" == "$this."* && "${objectName%*.*}" == "$this" ]] # "${this%%.*}" 
                then
                    local key=${objectName##*.}
                    local value="$($objectName.Serialize)"
                    nestedObject[$nestedCount]="\"$key\": $value"
                    nestedCount+=1
                    # echo "type: ${__oo__objects[$objectName]}"
                    # echo "name: $objectName"
                fi
            done
            if [[ $nestedCount -eq 0 ]]
            then
                local value="$($this)"
                if String.IsNumber "$value"
                then
                    echo "$value"
                else
                    echo "\"$value\""
                fi
            else
                echo -n "{ "
                nestedCount+=-1
                local serializedCount
                for serializedCount in "${!nestedObject[@]}"
                do
                    echo -n "${nestedObject[$serializedCount]}"
                    [[ $serializedCount -eq $nestedCount ]] || echo -n ", "
                done
                echo -n "} "
            fi
        }
    ~methods
}