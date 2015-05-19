namespace oo

## STORAGE ##

declare -ag __oo__importedTypes
declare -Ag __oo__storage
declare -Ag __oo__objects
declare -Ag __oo__objects_private
declare -ag __oo__functionsTernaryOperator

## TYPE SYSTEM ##

# the creation of a new object
Type.CreateInstance() {
    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
    local baseNow=${FUNCNAME[2]#*:}

    if [[ ! -z $extending ]]; then
        subject=level1 Log "basing ($baseNow) $fullName on $objectType..."

        # TODO: base cannot be set as $base because that means it cannot be called from the base
        # - the reference will always be to just that one base

        local baseType
        if Function.Exists "$fullName.__baseType__"
        then
            baseType="$($fullName.__baseType__)"
            subject=level2 Log "baseType = $baseType"
        fi
    else
        subject=level1 Log "initializing and constructing $fullName ($visibleAsType) of $objectType"
    fi

    ## add methods
    local instanceMethods=($(compgen -A 'function' $objectType:: || true))
    local staticMethods=($(compgen -A 'function' $objectType. || true))

    ## TODO: does this make sense?
    ## should we map static types?
    if [[ $fullName != $visibleAsType ]] && [[ ! -z "${staticMethods[*]}" ]]; then
        local method
        for method in "${staticMethods[@]}"; do

            # leave just function name from end
            method=${method##*.}

            subject=level2 Log "mapping static method: $fullName.$method ==> $method"
            #local parentName=${fullName%.*}

            # add method aliases
            #alias "$fullName.$method=self=$fullName __objectType__=$visibleAsType __parentType__=$parentType $objectType.$method "

            eval "$fullName.$method() {
                self=$fullName \
                __objectType__=$visibleAsType \
                __parentType__=$parentType \
                $objectType.$method \"\$@\"
            }"
        done
    fi

    ## instance methods hide static ones if the name is the same
    if [[ ! -z "${instanceMethods[*]}" ]]
    then
        local method
        for method in "${instanceMethods[@]}"; do

            # leave just function name from end
            method=${method##*::}

            subject=level2 Log "mapping instance method: $fullName.$method ==> $method"
            #local parentName=${fullName%.*}

            local baseMethod="$baseType::$method"

            # add method aliases
            #alias "$fullName.$method=this=$fullName baseMethod=$baseMethod base=$baseType __objectType__=$visibleAsType __parentType__=$parentType $objectType::$method"
            eval "$fullName.$method() {
                this=$fullName \
                baseMethod=$baseMethod \
                base=$baseType \
                __objectType__=$visibleAsType \
                __parentType__=$parentType \
                $objectType::$method \"\$@\"
            }"
        done
    fi

    # if extending:
    if [[ ! -z $extending ]]
    then
        eval "$fullName.__baseType__() {
            echo $baseNow
        }"
    else # if not extending
        eval "$fullName() {
            __objectType__=$objectType \
            __parentType__=$parentType \
            fullName=$fullName \
            Type.CallInstance \"\$@\"
        }"
    fi

    # TODO: why do we need to use eval to run the constructor in cases where it's an alias not a function?

    # First run with the arguments given only when an operator is in use
    if [[ ! -z "$1" ]]; then
        # do we use the constructor operator? ~~
        if [[ "$1" = '~~' ]]; then
            shift
            if Function.Exists $fullName.__constructor__
            then
                $fullName.__constructor__ "$@"
            fi
        else
            # we are immediately doing an operation, so use the default constructor and run the thing!
            if Function.Exists $fullName.__constructor__
            then
                $fullName.__constructor__
            fi
            $fullName "$@"
        fi
    else
        # just run the constructor if any
        if Function.Exists $fullName.__constructor__
        then
            $fullName.__constructor__
        fi
    fi
}

Type.CallInstance() {
    @var operator
    
    local caller="${FUNCNAME[3]%.*}"
    local parent="${fullName%.*}"

    ## TODO: access control 
    if [[ ${FUNCNAME[3]} != "Type.Initialize" && ! -z "${__oo__objects_private[$fullName]}" && "$caller" != "$parent" ]]
    then
        # echo private ${__oo__objects_private[$fullName]}
        #echo ${FUNCNAME[3]} - $caller / $parent
        # echo obj: $__objectType__ / $fullName
        # echo funcname: ${FUNCNAME[3]} / ${FUNCNAME[4]}
        e="Trying to access a private object" throw
        return 1
    fi

    # if no arguments, use the getter:
    [[ $@ ]] || {
        $fullName.__getter__;
        return $?
    }

    shift

    # if the parameter after the operator is empty...
    if [[ -z "${1+x}" ]]; then
        case "$operator" in
            '++') $fullName.__increment__ "$@" ;;
            '--') $fullName.__decrement__ "$@" ;;
            *)  throw "no value given"
                return 1 ;;
        esac
    else
        case "$operator" in
            '=') $fullName.__setter__ "$@" ;;
            '==') $fullName.__equals__ "$@" ;;
            '+') $fullName.__add__ "$@" ;;
            '-') $fullName.__subtract__ "$@" ;;
            '*') $fullName.__multiply__ "$@" ;;
            '/') $fullName.__divide__ "$@" ;;
        esac
    fi
}

Type.Exists(){
    @var type
    if ! Array.Contains "$type" "${__oo__importedTypes[@]}"
    then
        # type=${type#*:}
        Array.Contains "static:$type" "${__oo__importedTypes[@]}" || Array.Contains "class:$type" "${__oo__importedTypes[@]}" || return 1
    fi
    return 0
}

Type.Initialize() {
    @var objectType
    @var fullType
    @var newObjectName

    # TODO: @params paramsForInitializing
    shift; shift

    ## TODO: add name sanitization, like, you cannot create objects with DOTs (.)

    local parentType=${FUNCNAME[2]}
    [[ ! -z $__private__ && $__private__ == "true" ]] && parentType=${FUNCNAME[3]}
    parentType=${parentType#*:}
    
    local parentName="$fullName"

    subject=level1 Log "Running the initializer for: $objectType"
    subject=level1 Log "Type: $fullType"
    subject=level1 Log "Name: $newObjectName"
    subject=level1 Log "Params for initializing: $*"
    subject=level1 Log "Parent Type: $parentType"
    subject=level1 Log "Parent Name: $fullName"

    # TODO: add a check if parent is an object

    if [[ $parentType = $objectType ]]
    then
        throw 'recurrent nesting types within itself is not possible'
        return 1
    fi

    if [[ -z "$parentName" ]]
    then
        local fullName=$newObjectName;
    else
        local fullName=$parentName.$newObjectName
    fi
    
    subject=level1 Log "Full Name: $fullName"
    shift

    test ! -z "$fullName" || throw "No name ($newObjectName)? This shouldn\'t happen"
    
    __oo__objects["$fullName"]=$objectType

    if [[ ! -z $__private__ && $__private__ == "true" ]]; then
        subject=level1 Log "new private object $fullType, parent: $parentName"
        __oo__objects_private["$fullName"]=$objectType
    #else
    #    subject=level1 Log "new object $fullType, parent: $parentName"
    fi

    subject=level1 Log "Creating an instance of $fullType"
    instance=true $fullType

    subject=level1 Log "Initializing the instance of $fullType"
    Type.CreateInstance "$@"
    # TODO: Type.CreateInstance "${paramsForInitializing[@]}"
}

Type.Load(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A 'function' class: || true))
    types+=($(compgen -A 'function' static: || true))

    if [[ ${#types[@]} -eq 0 ]]; then
        subject=level1 Log "no types to import... : ${types[@]}"
    else
        local fullType
        local type

        for fullType in "${types[@]}"; do
            if ! Array.Contains "$fullType" "${__oo__importedTypes[@]}"; then

                # trim class: or static: from front
                type=${fullType#*:}

                # import methods if not static
                if [[ ${fullType:0:6} != "static" ]]
                then
                    subject=level1 Log "enabling type [ $fullType ]"
                    instance=false class:$type
                else
                    subject=level1 Log "enabling static type [ $fullType ]"
                fi

                # 'new' function for creating the object
                eval "$type() { Type.Initialize $type $fullType \"\$@\"; }"

                if [[ ${fullType:0:6} == "static" ]]
                then
                    ## static means singleton - simply replace the function with an instance ##
                    $type $type
                else
                    ## private definition only for non-static types ##
                    # TODO: if private, don't allow public access
                    #alias private:$type="__private__=true $type"
                    #eval "
                    #private:$type() {
                    #    __private__=true $type \"\$@\"
                    #}
                    #"

                    ## alias enabling to define parameters ##
                    subject=level4 Log "Aliasing @$type"
                    alias @$type="_type=$type @param"
                fi
            fi
        done
    fi

    ## update the list of imported types
    __oo__importedTypes=( "${types[@]}" )
}

Type.Extend() {
    # we can only extend when there's what to extend...
    if [[ ! -z $fullName ]]
    then
        local extensionType="$1"
        shift
        if Function.Exists "class:$extensionType"
        then
            class:$extensionType
            extending=true objectType=$extensionType Type.CreateInstance "$@"
        fi
    fi
}
