## STORAGE ##

declare -ag __oo__importedTypes
declare -Ag __oo__storage
declare -Ag __oo__objects
declare -Ag __oo__objects_private
declare -ag __oo__functionsTernaryOperator

## TYPE SYSTEM ##

Type.GetFullName(){
    @var thisName
    local parentName=$fullName

    if [[ -z "$parentName" ]]; then
        echo $thisName;
    else
        echo $parentName.$thisName;
    fi
}

# the creation of a new object
Type.CreateInstance() {
    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
    local baseNow=${FUNCNAME[2]#*:}

    if [[ ! -z $extending ]]; then
        Log.Debug 1 "basing ($baseNow) $fullName on $objectType..."

        # TODO: base cannot be set as $base because that means it cannot be called from the base
        # - the reference will always be to just that one base

        local baseType
        if Function.Exists "$fullName.__baseType__"
        then
            baseType="$($fullName.__baseType__)"
            Log.Debug 2 "baseType = $baseType"
        fi
    else
        Log.Debug 1 "initializing and constructing $fullName ($visibleAsType) of $objectType"
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

            Log.Debug 2 "mapping static method: $fullName.$method ==> $method"
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

            Log.Debug 2 "mapping instance method: $fullName.$method ==> $method"
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
    
    ## TODO: access control / private, etc.

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

    Log.Debug 1 "Running the initializer for: $objectType"
    Log.Debug 1 "Type: $fullType"
    Log.Debug 1 "Name: $newObjectName"
    Log.Debug 1 "Params for initializing: $*"

    ## TODO: add name sanitization, like, you cannot create objects with DOTs (.)

    local parentType=${FUNCNAME[2]}
    [[ ! -z $__private__ ]] && parentType=${FUNCNAME[3]}
    parentType=${parentType#*:}

    if [[ $parentType = $objectType ]]
    then
        throw 'recurrent nesting types within itself is not possible'
        return 1
    fi

    local parentName=$fullName
    local fullName=$(Type.GetFullName $newObjectName)
    shift

#    if test -z $fullName throw "No name? This shouldn\'t happen"
    __oo__objects["$fullName"]=$objectType

    if [[ ! -z $__private__ ]]; then
        Log.Debug 1 "new private object $type, parent: $parentName"
        __oo__objects_private["$fullName"]=$objectType
    else
        Log.Debug 1 "new object $type, parent: $parentName"
    fi

    Log.Debug 1 "Creating an instance of $fullType"
    instance=true $fullType

    Log.Debug 1 "Initializing the instance of $fullType"
    Type.CreateInstance "$@"
    # TODO: Type.CreateInstance "${paramsForInitializing[@]}"
}

Type.Load(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function class: || true))
    types+=($(compgen -A function static: || true))

    if [[ ${#types[@]} -eq 0 ]]; then
        Log.Debug 1 "no types to import... : ${types[@]}"
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
                    Log.Debug 1 "enabling type [ $fullType ]"
                    instance=false class:$type
                else
                    Log.Debug 1 "enabling static type [ $fullType ]"
                fi

                # 'new' function for creating the object
                eval "$type() { Type.Initialize $type $fullType \"\$@\"; }"

                # INFO: IF USING THE ALIAS VERSION REMEMBER TO LOWER FUNCNAME[NUM] INSIDE!
                #alias $type="Type.Initialize $type $fullType"

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
                    Log.Debug 4 "Aliasing @$type"
                    alias @$type="_type=$type @param"
#                    alias @$type="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( $type )\"; local "
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
