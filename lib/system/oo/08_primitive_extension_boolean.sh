### BOOLEAN

boolean.__getter__() {
  @resolve:this

  [[ "$this" == "${__primitive_extension_fingerprint__boolean}:true" ]]
}

boolean.toString() {
  @resolve:this

  if [[ "$this" == "${__primitive_extension_fingerprint__boolean}:true" ]]
  then
    @return:value true
  else
    @return:value false
  fi
}

boolean.=() {
  @resolve:this

  [string] value

  if [[ "$value" == "true" ]]
  then
    this="${__primitive_extension_fingerprint__boolean}:true"
  else
    this="${__primitive_extension_fingerprint__boolean}:false"
  fi

  @return
}

### /BOOLEAN