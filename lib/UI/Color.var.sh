alias UI.Color.IsAvailable='[ $(tput colors 2>/dev/null || echo 0) -ge 16 ] && [ -t 1 ]'
if UI.Color.IsAvailable
then
  UI_Color_Default=$'\033[0m'

  UI_Color_Black=$'\033[0;30m'
  UI_Color_Red=$'\033[0;31m'
  UI_Color_Green=$'\033[0;32m'
  UI_Color_Yellow=$'\033[0;33m'
  UI_Color_Blue=$'\033[0;34m'
  UI_Color_Magenta=$'\033[0;35m'
  UI_Color_Cyan=$'\033[0;36m'
  UI_Color_LightGray=$'\033[0;37m'

  UI_Color_DarkGray=$'\033[0;90m'
  UI_Color_LightRed=$'\033[0;91m'
  UI_Color_LightGreen=$'\033[0;92m'
  UI_Color_LightYellow=$'\033[0;93m'
  UI_Color_LightBlue=$'\033[0;94m'
  UI_Color_LightMagenta=$'\033[0;95m'
  UI_Color_LightCyan=$'\033[0;96m'
  UI_Color_White=$'\033[0;97m'

  # flags
  UI_Color_Bold=$'\033[1m'
  UI_Color_Dim=$'\033[2m'
  UI_Color_Italics=$'\033[3m'
  UI_Color_Underline=$'\033[4m'
  UI_Color_Blink=$'\033[5m'
  UI_Color_Invert=$'\033[7m'
  UI_Color_Invisible=$'\033[8m'

  UI_Color_NoBold=$'\033[21m'
  UI_Color_NoDim=$'\033[22m'
  UI_Color_NoItalics=$'\033[23m'
  UI_Color_NoUnderline=$'\033[24m'
  UI_Color_NoBlink=$'\033[25m'
  UI_Color_NoInvert=$'\033[27m'
  UI_Color_NoInvisible=$'\033[28m'
else
  UI_Color_Default=""

  UI_Color_Black=""
  UI_Color_Red=""
  UI_Color_Green=""
  UI_Color_Yellow=""
  UI_Color_Blue=""
  UI_Color_Magenta=""
  UI_Color_Cyan=""
  UI_Color_LightGray=""

  UI_Color_DarkGray=""
  UI_Color_LightRed=""
  UI_Color_LightGreen=""
  UI_Color_LightYellow=""
  UI_Color_LightBlue=""
  UI_Color_LightMagenta=""
  UI_Color_LightCyan=""
  UI_Color_White=""

  # flags
  UI_Color_Bold=""
  UI_Color_Dim=""
  UI_Color_Italics=""
  UI_Color_Underline=""
  UI_Color_Blink=""
  UI_Color_Invert=""
  UI_Color_Invisible=""

  UI_Color_NoBold=""
  UI_Color_NoDim=""
  UI_Color_NoItalics=""
  UI_Color_NoUnderline=""
  UI_Color_NoBlink=""
  UI_Color_NoInvert=""
  UI_Color_NoInvisible=""
fi

alias UI.Powerline.IsAvailable="UI.Color.IsAvailable && test -z \${NO_UNICODE-} && (echo -e $'\u1F3B7' | grep -v F3B7) &> /dev/null"
if UI.Powerline.IsAvailable
then
  UI_Powerline_PointingArrow=$'\u27a1'
  UI_Powerline_ArrowLeft=$'\ue0b2'
  UI_Powerline_ArrowRight=$'\ue0b0'
  UI_Powerline_ArrowRightDown=$'\u2198'
  UI_Powerline_ArrowDown=$'\u2B07'
  UI_Powerline_PlusMinus=$'\ue00b1'
  UI_Powerline_Branch=$'\ue0a0'
  UI_Powerline_RefersTo=$'\u27a6'
  UI_Powerline_OK=$'\u2714'
  UI_Powerline_Fail=$'\u2718'
  UI_Powerline_Lightning=$'\u26a1'
  UI_Powerline_Cog=$'\u2699'
  UI_Powerline_Heart=$'\u2764'

  # colorful
  UI_Powerline_Star=$'\u2b50'
  UI_Powerline_Saxophone=$'\U1F3B7'
  UI_Powerline_ThumbsUp=$'\U1F44D'
else
  UI_Powerline_PointingArrow="'~'"
  UI_Powerline_ArrowLeft="'<'"
  UI_Powerline_ArrowRight="'>'"
  UI_Powerline_ArrowRightDown="'>'"
  UI_Powerline_ArrowDown="'_'"
  UI_Powerline_PlusMinus="'+-'"
  UI_Powerline_Branch="'|}'"
  UI_Powerline_RefersTo="'*'"
  UI_Powerline_OK="'+'"
  UI_Powerline_Fail="'x'"
  UI_Powerline_Lightning="'!'"
  UI_Powerline_Cog="'{*}'"
  UI_Powerline_Heart="'<3'"

  # colorful
  UI_Powerline_Star="'*''"
  UI_Powerline_Saxophone="'(YEAH)'"
  UI_Powerline_ThumbsUp="'(OK)'"
fi

UI.Color.Print() {
  local -i colorCode="$1"

  if UI.Color.IsAvailable
  then
    local colorString="\$'\033[${colorCode}m'"
    eval echo "${colorString}"
  else
    echo
  fi
}

UI.Color.256text() {
  local -i colorNumber="$1"

  if UI.Color.IsAvailable
  then
    local colorString="\$'\033[38;5;${colorNumber}m'"
    eval echo "${colorString}"
  else
    echo
  fi
}

UI.Color.256background() {
  local -i colorNumber="$1"

  if UI.Color.IsAvailable
  then
    local colorString="\$'\033[48;5;${colorNumber}m'"
    eval echo "${colorString}"
  else
    echo
  fi
}
