class:UI.Cursor() {
  # http://askubuntu.com/questions/366103/saving-more-corsor-positions-with-tput-in-bash-terminal
	# http://unix.stackexchange.com/questions/88296/get-vertical-cursor-position

	private integer x
	private integer y

  UI.Cursor.capture() {
    local x
    local y
    IFS=';' read -sdR -p $'\E[6n' y x
    this y = $(( ${y#*[} - 1 ))
    this x = $(( ${x} - 1 ))

    # exec < /dev/tty
    # local oldstty=$(stty -g)
    # stty raw -echo min 0
    # echo -en "\033[6n" > /dev/tty
    # IFS=';' read -r -d R -a pos
    # stty $oldstty

    # this x = $((${pos[0]:2} - 2)) # TODO: needs to be - 2
    # this y = $((${pos[1]} - 1))

    @return
  }

  UI.Cursor.restore() {
    [integer] shift=1

    local -i totalHeight=$(tput lines)
    local -i y=$(this y)
    local -i x=$(this x)

    (( $y + 1 == $totalHeight )) && y+=-$shift

    tput cup $y $x

    @return
  }
}

Type::Initialize UI.Cursor