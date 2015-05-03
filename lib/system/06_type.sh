## KEYWORDS ##
alias extends="Type.Extend"

alias methods="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~methods="fi"
alias method="[[ -z \$instance ]] || [[ \$instance = false ]] &&"

alias statics="if [[ -z \$instance ]] || [[ \$instance = false ]]; then "
alias ~statics="fi"
alias static="[[ -z \$instance ]] || [[ \$instance = false ]] &&"

alias public="[[ \$instance = true ]] && __private__=false "
alias private="[[ \$instance = true ]] && __private__=true "

## TODO: add implementation & use inside of class declaration
alias oo:enable:TernaryOperator="__oo__functionsTernaryOperator+=( ${FUNCNAME[0]} )"

alias Object.Exists="Function.Exists"

Type.GetFullName(){
    local thisName=$1
    local parentName=$fullName
    if [[ -z "$parentName" ]]; then
        echo $thisName;
    else
        echo $parentName.$thisName;
    fi
}

# the creation of a new object
Type.CreateInstance(){
    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
    local baseNow=${FUNCNAME[2]#*:}

    if [[ ! -z $extending ]]; then
        Log.Debug 1 "oo: basing ($baseNow) $fullName on $objectType..."

        # TODO: base cannot be set as $base because that means it cannot be called from the base
        # - the reference will always be to just that one base
        local baseType
        if Function.Exists "$fullName.__baseType__"
        then
            baseType="$($fullName.__baseType__)"
            Log.Debug 2 "oo: baseType = $baseType"
        fi
    else
        Log.Debug 1 "oo: initializing and constructing $fullName ($visibleAsType) of $objectType"
    fi

    ## add methods
    local instanceMethods=($(compgen -A 'function' $objectType::))
    local staticMethods=($(compgen -A 'function' $objectType.))

    #    local methods=( "${instanceMethods[@]}" "${staticMethods[@]}" )

    ## TODO: does this make sense?
    ## should we map static types?
    if [[ $fullName != $visibleAsType ]] && [[ ! -z "${staticMethods[*]}" ]]; then
        local method
        for method in "${staticMethods[@]}"; do

            # leave just function name from end
            method=${method##*.}

            Log.Debug 2 "oo: mapping static method: $fullName.$method ==> $method"

            #local parentName=${fullName%.*}

            # add method aliases
#            alias $fullName.$method="self=$fullName __objectType__=$visibleAsType __parentType__=$parentType $objectType.$method"
            eval "$fullName.$method() {
                self=$fullName \
                __objectType__=$visibleAsType \
                __parentType__=$parentType \
                $objectType.$method \"\$@\"
            }"
        done
    fi

    ## instance methods hide static ones if the name is the same
    if [[ ! -z "${instanceMethods[*]}" ]]; then
        local method
        for method in "${instanceMethods[@]}"; do

            # leave just function name from end
            method=${method##*::}

            Log.Debug 2 "oo: mapping instance method: $fullName.$method ==> $method"

            #local parentName=${fullName%.*}

            local baseMethod="$baseType::$method"

            #            [ ! -z $extending ] && {
            #                Function.Exists "$fullName.__baseType__" && {
            #                    baseType="$($fullName.__baseType__)"
            #                    Function.Exists "$baseType::$method" && {
            #                        base="$baseType::$method"
            #                    }
            #                }
            #            }

            # add method aliases
            #alias $fullName.$method="this=$fullName baseMethod=$baseMethod base=$baseType __objectType__=$visibleAsType __parentType__=$parentType $objectType::$method"
            eval "$fullName.$method() {
                this=$fullName \
                baseMethod=$baseMethod \
                base=$baseType \
                __objectType__=$visibleAsType \
                __parentType__=$parentType \
                $objectType::$method \"\$@\"
                }"

        #eval "
        #    $fullName.$method() {
        #        local this=$fullName
        #        local baseMethod=$baseMethod
        #        local base=$baseType
        #        local __objectType__=$visibleAsType
        #        local __parentType__=$parentType
        #        $objectType::$method \"\$@\"
        #    }
        #    "
        done
    fi


    # if extending:
    if [[ ! -z $extending ]]
    then
        eval "$fullName.__baseType__() {
#           echo $objectType
            echo $baseNow
        }"
    else
        # if not extending
        eval "$fullName() {
            __objectType__=$objectType \
            __parentType__=$parentType \
            fullName=$fullName \
            Type.CallInstance \"\$@\"
        }"
    # if not extending:
    #alias $fullName="__objectType__=$objectType __parentType__=$parentType fullName=$fullName Type.CallInstance"
    fi

    # TODO: why do we need to use eval to run the constructor it's an alias not a function?
    # first run with the arguments given only when an operator is in use
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
    ## TODO: access control / private, etc.

    #Log.Debug 1 "oo: CALL STACK: ${FUNCNAME[@]}"
    #            Array.Contains __oo__objects_private "${__oo__objects_private[@]}" || {
    #                parentType=${FUNCNAME[2]}
    #                [[ ${parentType%%:*} = 'Type' ]] && {
    #                    throw cannot access private type
    #                    return 1
    #                }
    #            }

    # if no arguments, use the getter:
    [[ $@ ]] || {
        eval $fullName.__getter__;
        return $?
    }

    local operator="$1"; shift

    # if the parameter after the operator is empty...
    if [[ -z "${1+x}" ]]; then
        case "$operator" in
            '++') eval $fullName.__increment__ "$@" ;;
            '--') eval $fullName.__decrement__ "$@" ;;
            *)  throw "no value given"
            return 1 ;;
        esac
    else
        case "$operator" in
            '=') eval $fullName.__setter__ "$@" ;;
            '==') eval $fullName.__equals__ "$@" ;;
            '+') eval $fullName.__add__ "$@" ;;
            '-') eval $fullName.__subtract__ "$@" ;;
            '*') eval $fullName.__multiply__ "$@" ;;
            '/') eval $fullName.__divide__ "$@" ;;
        esac
    fi
}

Type.Exists(){
    local type=${1#*:}
    Array.Contains "static:$type" "${__oo__importedTypes[@]}" || Array.Contains "class:$type" "${__oo__importedTypes[@]}"
    return $?
}

Type.Load(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function class:)) # | grep -v ::
    types+=($(compgen -A function static:))

    if [[ ${#types[@]} -eq 0 ]]; then
        Log.Debug 1 "oo: no types to import... : ${types[@]}"
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
                    Log.Debug 1 "oo: enabling type [ $fullType ]"
                    instance=false class:$type
                else
                    Log.Debug 1 "oo: enabling static type [ $fullType ]"
                fi

                typeInitializer() {
                    : @mixed objectType
                    : @mixed fullType
                    : @mixed newObjectName
                    @@verify
                    # TODO: @params paramsForInitializing
                    shift; shift

                    Log.Debug 1 Running the initializer for: $objectType
                    Log.Debug 1 Type: $fullType
                    Log.Debug 1 Name: $newObjectName
                    Log.Debug 1 Params for the initializing: $*

                    ## TODO: add name sanitization, like, you cannot create objects with DOTs (.)

                    local parentType=${FUNCNAME[2]}
                    [[ ! -z $__private__ ]] && parentType=${FUNCNAME[3]}
                    parentType=${parentType#*:}

                    if [[ $parentType = $objectType ]]; then
                        throw 'recurrent nesting types within itself is not possible'
                        return 1
                    fi

                    local parentName=$fullName
                    local fullName=$(Type.GetFullName $newObjectName)
                    shift

                    #echo $newObjectName s fullName is: $fullName
                    __oo__objects["$fullName"]=$objectType

                    if [[ -z $__private__ ]]; then
                        Log.Debug 1 oo: new object $type, parent: $parentName
                    else
                        Log.Debug 1 oo: new private object $type, parent: $parentName
                        __oo__objects_private["$fullName"]=$objectType
                    fi

                    #try
                    Log.Debug 1 "Creating an instance of $fullType"
                    instance=true $fullType
                    #catch
                    #throw "Unable to create the instance ($THROW_LINE)"

                    #try
                    Log.Debug 1 "Initializing the instance of $fullType"
                    Type.CreateInstance "$@"
                    # TODO: Type.CreateInstance "${paramsForInitializing[@]}"
                    #catch
                    #throw "Unable to create initialize the instance ($THROW_LINE)"
                }

                # 'new' function for creating the object
                eval "$type() { typeInitializer $type $fullType \"\$@\"; }"

                # INFO: IF USING THE ALIAS VERSION REMEMBER TO LOWER FUNCNAME[NUM] INSIDE!
                #alias $type="typeInitializer $type $fullType"

                if [[ ${fullType:0:6} == "static" ]]; then
                    #{
                    ## static means singleton - simply replace the function with an instance ##
                    # TODO: why do we need to eval with aliases?
                    $type $type
                #}
                else
                    #{
                    ## private definition only for non-static types ##
                    # TODO: if private, don't allow public access
                    alias private:$type="__private__=true $type"
                    #eval "
                    #private:$type() {
                    #    __private__=true $type \"\$@\"
                    #}
                    #"

                    ## alias enabling to define parameters ##
                    Log.Debug 4 "Aliasing @$type"
                    alias @$type="Function.StashPreviousLocal; declare -a \"__oo__param_types+=( $type )\"; local "
                    #eval "alias @$type=\"Function.StashPreviousLocal; declare -a \\\"__oo__param_types+=( $type )\\\"; local \""

                    #eval "alias \"@$type=echo I alias\""
                    #shopt -s expand_aliases

                #}
                fi
            fi
        done
    fi

    ## update the list of imported types
    __oo__importedTypes=("${types[@]}")
}

Type.Extend() {
    # we can only extend when there's what to extend...
    if [[ ! -z $fullName ]]; then
        local extensionType="$1"
        shift
        if Function.Exists "class:$extensionType"
        then
            class:$extensionType
            extending=true objectType=$extensionType Type.CreateInstance "$@"
        fi
    fi
}
