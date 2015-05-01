import ../base/Object

static:UI.Powerline() {
    extends Object
	alias UI.Powerline.PointingArrow="UI.Unicode.Print '\u27a1'"
	alias UI.Powerline.ArrowLeft="UI.Unicode.Print '\ue0b2'"
	alias UI.Powerline.ArrowRight="UI.Unicode.Print '\ue0b0'"
	alias UI.Powerline.PlusMinus="UI.Unicode.Print '\ue00b1'"
	alias UI.Powerline.Branch="UI.Unicode.Print '\ue0a0'"
	alias UI.Powerline.RefersTo="UI.Unicode.Print '\u27a6'"
	alias UI.Powerline.OK="UI.Unicode.Print '\u2714'"
	alias UI.Powerline.Fail="UI.Unicode.Print '\u2718'"
	alias UI.Powerline.Lightning="UI.Unicode.Print '\u26a1'"
	alias UI.Powerline.Cog="UI.Unicode.Print '\u2699'"
	alias UI.Powerline.Heart="UI.Unicode.Print '\u2764'"
	
	# colorful
	alias UI.Powerline.Star="UI.Unicode.Print '\u2b50'"
	alias UI.Powerline.Saxophone="UI.Unicode.Print $'\U1F3B7'"
	alias UI.Powerline.ThumbsUp="UI.Unicode.Print $'\U1F44D'"
}

#class:UnicodeString() {
#	extends Const
#
#	UnicodeString::__getter__() {
#		[ ! -z $this ] && echo -e "${__oo__storage[$this]}"
#	}
#}
#
#static:UI.Unicode() {
#	UI.Unicode.Print() {
#		echo -e "$1"
#	}
#}
