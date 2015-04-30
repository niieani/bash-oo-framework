class:UICursor() {
	extends Object
	
	public Number X = 0
	public Number Y = 0
	
	methods
		UICursor::Capture() {
		    exec < /dev/tty
		    local oldstty=$(stty -g)
		    stty raw -echo min 0
		    echo -en "\033[6n" > /dev/tty
		    IFS=';' read -r -d R -a pos
		    stty $oldstty
			$this.X = ${pos[0]:2}
			$this.Y = ${pos[1]}
			$this.X - 2
			$this.Y - 1
		    #eval "$1[0]=$((${pos[0]:2} - 2))"
		    #eval "$1[1]=$((${pos[1]} - 1))"
		}
		
		UICursor::Restore() {
			tput cup $($this.X) $($this.Y)
		}
	~methods
} && oo:enableType

