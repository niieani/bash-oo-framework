## KEYWORDS ##
alias extends="oo:extends"

alias methods="if ! \$instance; then : "
alias ~methods="fi"
alias method="test ! \$instance && "

alias statics="if ! \$instance; then : "
alias ~statics="fi"
alias static="test ! \$instance && "

alias public="test \$instance && local __oo__public=true && "
alias private="test \$instance && local __oo__public=false && "

## TODO:
alias oo:enable:TernaryOperator="__oo__functionsTernaryOperator+=( ${FUNCNAME[0]} )"

oo:extends() {
  # we can only extend when there's what to extend...
  if [ ! -z $fullName ]; then
    local extensionType="$1"
    shift
    oo:isMethodDeclared "class:$extensionType" && {
      class:$extensionType
      extending=true objectType=$extensionType oo:initialize "$@"
    }
  fi
}

oo:assignParamsToLocal() {
    ## unset first miss
    unset __oo__params[0]

    ## TODO: if no params were defined, we can add ternary operator and others
    # __oo__functionsTernaryOperator+=( ${FUNCNAME[1]} )

    declare -i i
    local iparam
    local variable
    local type
    for i in "${!__oo__params[@]}"
    do
        oo:debug:3 "i    : $i"

        iparam=$i

        variable="${__oo__params[$i]}"
        oo:debug:3 "var  : ${__oo__params[$i]}"

        i+=-1

        type="${__oo__param_types[$i]}"
        oo:debug:3 "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct
        # test if the types are right, if not, add note and "read" to wait for user input
        # assign correct values approprietly so they are avail later on

        if [ $type = 'params' ]; then
            for _x in "${!__oo__params[@]}"
            do
                oo:debug:3 "oo: we are params so we shift"
                [ "${__oo__param_types[$_x]}" != 'params' ] && eval shift
            done
            eval "$variable=\"\$@\""
#            $variable="$@"
#            return
        else
            ## assign value ##

            oo:debug:3 "value: ${!iparam}"
#           eval "$variable=\"${!iparam}\""
            eval "$variable=\"\$$iparam\""
        fi
    done

    unset __oo__params
    unset __oo__param_types
}

alias oo:stashPreviousLocal="declare -a \"__oo__params+=( \$_ )\""
alias @@verify="oo:stashPreviousLocal; oo:assignParamsToLocal " # ; for i in \${!__oo__params[@]}; do
alias @params="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "
alias @mixed="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( mixed )\"; local "

oo:getFullName(){
    local thisName=$1
    local parentName=$fullName
    if [ -z "$parentName" ]; then
        echo $thisName;
    else
        echo $parentName.$thisName;
    fi
}

oo:isMethodDeclared() {
    local fullMethodName="$1"
    # http://stackoverflow.com/questions/511683/bash-get-list-of-commands-starting-with-a-given-string
    local compgenOutput=($(compgen -A function "$fullMethodName"))
    ## TODO: add exact matching
    [[ ${#compgenOutput[@]} -gt 0 ]] && return 0
    return 1
}

oo:initialize(){
    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
    local baseNow=${FUNCNAME[2]#*:}

    [ -z $extending ] || oo:debug "oo: basing ($baseNow) $fullName on $objectType..."
    [ -z $extending ] && oo:debug "oo: initializing and constructing $fullName ($visibleAsType) of $objectType"

    ## add methods
    local instanceMethods=($(compgen -A function $objectType::))
    local staticMethods=($(compgen -A function $objectType.))

#    local methods=( "${instanceMethods[@]}" "${staticMethods[@]}" )

    # TODO: base cannot be set as $base because that means it cannot be called from the base
    # - the reference will always be to just that one base
    local baseType
    oo:isMethodDeclared "$fullName.__baseType__" && {
        baseType="$($fullName.__baseType__)"
        oo:debug:3 "oo: baseType = $baseType"
    }

    if [ ! -z "${instanceMethods[*]}" ]; then
        local method
        for method in "${instanceMethods[@]}"; do

            # leave just function name from end
            method=${method##*::}

            oo:debug:3 "oo: mapping method: $fullName.$method ==> $method"

            #local parentName=${fullName%.*}

            local baseMethod="$baseType::$method"

#            [ ! -z $extending ] && {
#                oo:isMethodDeclared "$fullName.__baseType__" && {
#                    baseType="$($fullName.__baseType__)"
#                    oo:isMethodDeclared "$baseType::$method" && {
#                        base="$baseType::$method"
#                    }
#                }
#            }

            # add method aliases
            eval "
                $fullName.$method() {
                    local this=$fullName
                    local baseMethod=$baseMethod
                    local base=$baseType
                    local __objectType__=$visibleAsType
                    local __parentType__=$parentType
                    $objectType::$method \"\$@\"
                }
                "
        done
    fi

    ## don't map static types
    if [[ $fullName != $visibleAsType ]] && [ ! -z "${staticMethods[*]}" ]; then
        local method
        for method in "${staticMethods[@]}"; do

            # leave just function name from end
            method=${method##*.}

            oo:debug:2 "oo: mapping static method: $fullName.$method ==> $method"

            #local parentName=${fullName%.*}

            # add method aliases
            eval "
                $fullName.$method() {
                    local self=$fullName
                    local __objectType__=$visibleAsType
                    local __parentType__=$parentType
                    $objectType.$method \"\$@\"
                }
                "
        done
    fi

    # if not extending:
    [ -z $extending ] && eval "
        $fullName() {

            ## TODO: access control / private, etc.

            #oo:debug \"oo: CALL STACK: \${FUNCNAME[@]}\"
#            oo:array:contains __oo__objects_private \"${__oo__objects_private[@]}\" || {
#                parentType=\${FUNCNAME[2]}
#                [[ \${parentType%%:*} = 'Type' ]] && {
#                    oo:throw cannot access private type
#                    return 1
#                }
#            }

            local __objectType__=$objectType
            local __parentType__=$parentType

            # if no arguments, use the getter:
            [[ \$@ ]] || {
                $fullName.__getter__;
                return 0
            }

            local operator=\"\$1\"; shift
            if [ -z \"\$1\" ]; then
                case \"\$operator\" in
                    '++') $fullName.__increment__ \"\$@\" ;;
                    '--') $fullName.__decrement__ \"\$@\" ;;
                    *)  oo:throw no value given
                        return 1 ;;
                esac
            else
                case \"\$operator\" in
                    '=') $fullName.__setter__ \"\$@\" ;;
                    '==') $fullName.__equals__ \"\$@\" ;;
                    '+') $fullName.__add__ \"\$@\" ;;
                    '-') $fullName.__substract__ \"\$@\" ;;
                    '*') $fullName.__multiply__ \"\$@\" ;;
                    '/') $fullName.__divide__ \"\$@\" ;;
                esac
            fi
        }
        "

    # first run with the arguments given only when an operator is in use
    if [ ! -z "$1" ]; then
        # do we use the constructor operator? ~~
        if [ "$1" = '~~' ]; then
            shift
            oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__ "$@"
        else
            # we are immediately doing an operation, so use the default constructor and run the thing!
            oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__
            $fullName "$@"
        fi
    else
        # just run the constructor if any
        oo:isMethodDeclared $fullName.__constructor__ && $fullName.__constructor__
    fi

    [ ! -z $extending ] &&
    eval "$fullName.__baseType__() {
#        echo $objectType
        echo $baseNow
    }"
}

oo:enableType(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function class:)) # | grep -v ::
    types+=($(compgen -A function static:))

    if [ ${#types[@]} -eq 0 ]; then
        oo:debug "oo: no types to import... : ${types[@]}"
    else
        local fullType
        local type
        for fullType in "${types[@]}"; do
            if ! oo:array:contains "$fullType" "${__oo__importedTypes[@]}"; then

                # trim class: or static: from front
                type=${fullType#*:}

                # import methods if not static
                if [[ ${fullType:0:6} != "static" ]]; then
                {
                    oo:debug "oo: enabling type [ $fullType ]"
                    instance=false class:$type
                }
                else
                {
                    oo:debug "oo: enabling static type [ $fullType ]"
                }
                fi

                # 'new' function for creating the object
                eval "
                $type() {
                    ## TODO: add name sanitization, like, you cannot create objects with DOTs (.)

                    local parentType=\${FUNCNAME[1]}
                    [[ ! -z \$__private__ ]] && parentType=\${FUNCNAME[2]}
                    parentType=\${parentType#*:}
                    local objectType=$type

                    if [ \$parentType = \$objectType ]; then
                        oo:throw 'recurrent nesting types within itself is not possible'
                        return 1
                    fi

                    local parentName=\$fullName
                    local fullName=\$(oo:getFullName \$1)
                    shift

                    __oo__objects[\"\$fullName\"]=\$objectType

                    if [[ -z \$__private__ ]]; then
                        oo:debug oo: new object $type, parent: \$parentName
                    else
                        oo:debug oo: new private object $type, parent: \$parentName
                        __oo__objects_private[\"\$fullName\"]=\$objectType
                    fi

                    $fullType
                    oo:initialize \"\$@\"
                }
                "

                if [[ ${fullType:0:6} == "static" ]]; then
                {
                    ## static means singleton - simply replace the function with an instance ##
                    $type $type
                }
                else
                {
                    ## private definition only for non-static types ##
                    eval "
                    # TODO: if private, don't allow public access

                    private:$type() {
                        __private__=true $type \"\$@\"
                    }
                    "

                    ## alias enabling to define parameters ##
                    alias @$type="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( $type )\"; local "
                }
                fi
            fi
        done
    fi

    ## update the list of imported types
    __oo__importedTypes=("${types[@]}")
}
