import ../base/Object

class:UI.Cursor() {
    # http://askubuntu.com/questions/366103/saving-more-corsor-positions-with-tput-in-bash-terminal
	extends Object
	
	public Number X = 0
	public Number Y = 0
	
	methods
		UI.Cursor::Capture() {
		    exec < /dev/tty
		    local oldstty=$(stty -g)
		    stty raw -echo min 0
		    echo -en "\033[6n" > /dev/tty
		    IFS=';' read -r -d R -a pos
		    stty $oldstty
			local x=${pos[0]:2}
			local y=${pos[1]}
			$this.X = $(($x - 2))
			$this.Y = $(($y - 1))
			#$this.X = $(this.X - 2)
			#$this.Y = $(this.Y - 1)
		    #eval "$1[0]=$((${pos[0]:2} - 2))"
		    #eval "$1[1]=$((${pos[1]} - 1))"
		}
		
		UI.Cursor::Restore() {
			tput cup $($this.X) $($this.Y)
		}
	~methods
}

