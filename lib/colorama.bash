#!/bin/bash


array=(
"""
        </> kesalahan $1
            argumen tidak terdaftar
             syntax $1 eror
"""
)

: '
    author : Bayu riski
 
mode :
       bold
       normal
       stop

list color :
            merah
            hijau
            kuning
            biru
            pink
            cyan
            putih
'

# report bug : +6285731184377
# email      : bayuriski558@gmail.com

function bold {

if (( $? == 0 )); then {
    wait
}
 else {
     str=1
  }
 fi

case $1 in
              hitam){
                      { ( setterm --foreground black --bold off ) }
                     } ;;
              merah){
                      { ( setterm --foreground red --bold on ) }
                    } ;;
              hijau){
                      { ( setterm --foreground green --bold on ) }
                    } ;;
              kuning){
                        { ( setterm --foreground yellow --bold on ) }
                     }
                      ;;
              biru){
                     { ( setterm --foreground blue --bold on ) }
                   } ;;
              pink)(setterm --foreground magenta --bold on) ;;
              cyan)(setterm --foreground cyan --bold on) ;;
              putih)(setterm --foreground white --bold on) ;;
              \<*): killall setterm ;;
              *)echo "${array[*]}"; exit 4
    ;;
esac


}

function normal {

if (( $? == 0 )); then
   str=${1}
 else
     str=1
 fi

case $1 in
              hitam)(setterm --foreground black --bold off) ;;
              merah)(setterm --foreground red --bold off) ;;
              hijau)(setterm --foreground green --bold off) ;;
              kuning)(setterm --foreground yellow --bold off) ;;
              biru)(setterm --foreground blue --bold off) ;;
              pink)(setterm --foreground magenta --bold off) ;;
              cyan)(setterm --foreground cyan --bold off) ;;
              putih)(setterm --foreground white --bold off) ;;
              *)echo "${array[*]}"; exit 4
    ;;
esac
}

function stop {
        {
          ( setterm --foreground default )
        }
         return 0
         wait
}

function blink {
        # comming soon
        shift
}
