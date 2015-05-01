## KEYWORDS ##
alias extends="oo:extends"

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

oo:extends() {
  # we can only extend when there's what to extend...
  if [[ ! -z $fullName ]]; then
    local extensionType="$1"
    shift
    if oo:isMethodDeclared "class:$extensionType"
    then
      class:$extensionType
      extending=true objectType=$extensionType oo:initialize "$@"
    fi
  fi
}

oo:assignParamsToLocal(){
    ## unset first miss
    unset '__oo__params[0]'

    ## TODO: if no params were defined, we can add ternary operator and others
    # __oo__functionsTernaryOperator+=( ${FUNCNAME[1]} )

    declare -i i
    local iparam
    local variable
    local type
    local optional=false
    for i in "${!__oo__params[@]}"
    do
        oo:debug:3 "i    : $i"

        iparam=$i

        ### TODO: variable might be optional, in this case we test if it has '=' sign and split it
        ### then we assign a variable optional=true and only require input for those that aren't optional

        variable="${__oo__params[$i]}"
        oo:debug:3 "var  : ${__oo__params[$i]}"

        i+=-1

        type="${__oo__param_types[$i]}"
        oo:debug:3 "type : ${__oo__param_types[$i]}"

        ### TODO: check if type is correct
        # test if the types are right, if not, add note and "read" to wait for user input
        # assign correct values approprietly so they are avail later on

        if [[ $type = 'params' ]]; then
            for _x in "${!__oo__params[@]}"
            do
                oo:debug:3 "oo: we are params so we shift"
                [[ "${__oo__param_types[$_x]}" != 'params' ]] && eval shift
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

alias oo:stashPreviousLocal="declare -a \"__oo__params+=( '\$_' )\""
alias @@verify="oo:stashPreviousLocal; oo:assignParamsToLocal \"\$@\"" # ; for i in \${!__oo__params[@]}; do
alias @params="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( params )\"; local "
alias @mixed="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( mixed )\"; local "

oo:getFullName(){
    local thisName=$1
    local parentName=$fullName
    if [[ -z "$parentName" ]]; then
        echo $thisName;
    else
        echo $parentName.$thisName;
    fi
}



oo:isMethodDeclared(){
    local fullMethodName="$1"
    #echo checking method $fullMethodName
    # http://stackoverflow.com/questions/511683/bash-get-list-of-commands-starting-with-a-given-string
    local compgenFunctions=($(compgen -A 'function' "$fullMethodName"))
    local compgenAliases=($(compgen -A 'alias' "$fullMethodName"))
    ## TODO: add exact matching
    [[ ${#compgenFunctions[@]} -gt 0 ]] || [[ ${#compgenAliases[@]} -gt 0 ]] && return 0
    return 1
}

# the creation of a new object
oo:initialize(){
    # if we are extending, then let's save the real type
    local visibleAsType="${__oo__objects["$fullName"]}"
    local baseNow=${FUNCNAME[2]#*:}

    [[ -z $extending ]] || oo:debug "oo: basing ($baseNow) $fullName on $objectType..."
    [[ -z $extending ]] && oo:debug "oo: initializing and constructing $fullName ($visibleAsType) of $objectType"

    ## add methods
    local instanceMethods=($(compgen -A 'function' $objectType::))
    local staticMethods=($(compgen -A 'function' $objectType.))

#    local methods=( "${instanceMethods[@]}" "${staticMethods[@]}" )

    # TODO: base cannot be set as $base because that means it cannot be called from the base
    # - the reference will always be to just that one base
    local baseType
    if oo:isMethodDeclared "$fullName.__baseType__"
    then
        baseType="$($fullName.__baseType__)"
        oo:debug:3 "oo: baseType = $baseType"
    fi

    ## TODO: does this make sense?
    ## don't map static types
    if [[ $fullName != $visibleAsType ]] && [[ ! -z "${staticMethods[*]}" ]]; then
        local method
        for method in "${staticMethods[@]}"; do

            # leave just function name from end
            method=${method##*.}

            oo:debug:3 "oo: mapping static method: $fullName.$method ==> $method"

            #local parentName=${fullName%.*}

            # add method aliases
            #alias $fullName.$method="self=$fullName __objectType__=$visibleAsType __parentType__=$parentType $objectType.$method"
            eval "$fullName.$method() { 
                self=$fullName \
                __objectType__=$visibleAsType \
                __parentType__=$parentType \
                $objectType.$method \"\$@\" 
            }"
            #eval "
            #$fullName.$method() {
            #    local self=$fullName
            #    local __objectType__=$visibleAsType
            #    local __parentType__=$parentType
            #    $objectType.$method \"\$@\"
            #}
            #"
        done
    fi

    ## instance methods hide static ones if the name is the same
    if [[ ! -z "${instanceMethods[*]}" ]]; then
        local method
        for method in "${instanceMethods[@]}"; do

            # leave just function name from end
            method=${method##*::}

            oo:debug:3 "oo: mapping instance method: $fullName.$method ==> $method"

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

    callObject() {
            ## TODO: access control / private, etc.

            #oo:debug "oo: CALL STACK: ${FUNCNAME[@]}"
#            oo:array:contains __oo__objects_private "${__oo__objects_private[@]}" || {
#                parentType=${FUNCNAME[2]}
#                [[ ${parentType%%:*} = 'Type' ]] && {
#                    oo:throw cannot access private type
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
                    *)  oo:throw "no value given"
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
            callObject \"\$@\" 
        }"
        # if not extending:
        #alias $fullName="__objectType__=$objectType __parentType__=$parentType fullName=$fullName callObject"
    fi
    
    # TODO: why do we need to use eval to run the constructor it's an alias not a function?
    # first run with the arguments given only when an operator is in use
    if [[ ! -z "$1" ]]; then
        # do we use the constructor operator? ~~
        if [[ "$1" = '~~' ]]; then
            shift
            if oo:isMethodDeclared $fullName.__constructor__
            then
                $fullName.__constructor__ "$@"
            fi
        else
            # we are immediately doing an operation, so use the default constructor and run the thing!
            if oo:isMethodDeclared $fullName.__constructor__
            then
                $fullName.__constructor__
            fi
            $fullName "$@"
        fi
    else
        # just run the constructor if any
        if oo:isMethodDeclared $fullName.__constructor__
        then
            $fullName.__constructor__
        fi
    fi
}

oo:enableType(){
    ## match Types (:) but not Methods (::) ##
    local types=($(compgen -A function class:)) # | grep -v ::
    types+=($(compgen -A function static:))

    if [[ ${#types[@]} -eq 0 ]]; then
        oo:debug "oo: no types to import... : ${types[@]}"
    else
        local fullType
        local type
        for fullType in "${types[@]}"; do
            if ! oo:array:contains "$fullType" "${__oo__importedTypes[@]}"; then

                # trim class: or static: from front
                type=${fullType#*:}

                # import methods if not static
                if [[ ${fullType:0:6} != "static" ]]
                then
                    oo:debug "oo: enabling type [ $fullType ]"
                    instance=false class:$type
                else
                    oo:debug "oo: enabling static type [ $fullType ]"
                fi

                oo:debug "oo: building the constructor for [ $type ]"
                
                typeInitializer() {
                    @mixed objectType
                    @mixed fullType
                    @mixed newObjectName
                    @@verify
                    # TODO: @params paramsForInitializing
                    shift; shift
                    
                    oo:debug Running the initializer for: $objectType
                    oo:debug Type: $fullType
                    oo:debug Name: $newObjectName
                    oo:debug Params for the initializing: $*
                    
                    ## TODO: add name sanitization, like, you cannot create objects with DOTs (.)

                    local parentType=${FUNCNAME[2]}
                    [[ ! -z $__private__ ]] && parentType=${FUNCNAME[3]}
                    parentType=${parentType#*:}

                    if [[ $parentType = $objectType ]]; then
                        oo:throw 'recurrent nesting types within itself is not possible'
                        return 1
                    fi

                    local parentName=$fullName
                    local fullName=$(oo:getFullName $newObjectName)
                    shift

                    #echo $newObjectName s fullName is: $fullName 
                    __oo__objects["$fullName"]=$objectType

                    if [[ -z $__private__ ]]; then
                        oo:debug oo: new object $type, parent: $parentName
                    else
                        oo:debug oo: new private object $type, parent: $parentName
                        __oo__objects_private["$fullName"]=$objectType
                    fi
                    
                    #try
                        oo:debug "Creating an instance of $fullType"
                        instance=true $fullType
                    #catch
                        #oo:throw "Unable to create the instance ($THROW_LINE)"
                        
                    #try
                        oo:debug "Initializing the instance of $fullType"
                        oo:initialize "$@"
                        # TODO: oo:initialize "${paramsForInitializing[@]}"
                    #catch
                        #oo:throw "Unable to create initialize the instance ($THROW_LINE)"
                }
                
                # 'new' function for creating the object
                eval "$type() { 
                    typeInitializer $type $fullType \"\$@\" 
                }"
                # INFO: IF USING THE ALIAS VERSION REMEMBER TO LOWER FUNCNAME[NUM] INSIDE!
                #alias $type="typeInitializer $type $fullType" 

                if [[ ${fullType:0:6} == "static" ]]; then
                #{
                    ## static means singleton - simply replace the function with an instance ##
                    # TODO: why do we need to eval?
                    eval $type $type
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
                    alias @$type="oo:stashPreviousLocal; declare -a \"__oo__param_types+=( $type )\"; local "
                #}
                fi
            fi
        done
    fi

    ## update the list of imported types
    __oo__importedTypes=("${types[@]}")
}

command_not_found_handle () {
    local script="${BASH_SOURCE[1]}"
    local prefix='./'
    local lineNo=${BASH_LINENO[0]}
    local undefinedObject=$*
    local errLine=$(sed "${lineNo}q;d" "$script")
    local underlinedObject="$(UI.Color.Magenta)$(UI.Color.Underline)$undefinedObject"$(UI.Color.White)$(UI.Color.NoUnderline)
    local underlinedObjectInLine="${errLine/$undefinedObject/$underlinedObject}"
    underlinedObjectInLine="$(String.Trim "$underlinedObjectInLine")"
    script="${script#$prefix}"
    if oo:isMethodDeclared UI.Color
    then
        echo
        echo $(UI.Color.Red)Undefined object: 
        #echo "  $(UI.Color.Underline)$(UI.Color.White)$*$(UI.Color.Default)"
        #echo $(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.Magenta)${errLine}$(UI.Color.Default)
        echo "$(UI.Color.Blue)[${script}:${lineNo}] $(UI.Color.White)${underlinedObjectInLine}$(UI.Color.Default)"
        echo
    else
        echo [${script}:${lineNo}] Undefined object: $*
    fi
    return 127
}
