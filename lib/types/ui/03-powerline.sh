class:UnicodeString() {
	extends Const
	
	UnicodeString::__getter__() {
		[ ! -z $this ] && echo -e "${__oo__storage[$this]}"
	}
} && oo:enableType


static:UI.Powerline() {
    extends Object
	UnicodeString PointingArrow = "\u27a1"
	UnicodeString ArrowLeft = "\ue0b2"
	UnicodeString ArrowRight = "\ue0b0"
	UnicodeString PlusMinus = "\ue00b1"
	UnicodeString Branch = "\ue0a0"
	UnicodeString RefersTo = "\u27a6"
	UnicodeString OK = "\u2714"
	UnicodeString Fail = "\u2718"
	UnicodeString Lightning = "\u26a1"
	UnicodeString Cog = "\u2699"
	UnicodeString Heart = "\u2764"
	
	# colorful
	UnicodeString Star = "\u2b50"
	UnicodeString Saxophone = $'\U1F3B7'
	UnicodeString ThumbsUp = $'\U1F44D'
} && oo:enableType
