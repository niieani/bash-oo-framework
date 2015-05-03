import ../base/Object

# Don't use colors on pipes or non-recognized terminals
#[[ "${TERM}" == *"xterm"* ]] || [ ! -t 1 ] &&
static:UI.Color() {
    extends Object

    UI.Color.IsAvailable() {
        # TODO: @@verify "$@" ## adds a ternary operator

        if [[ "${TERM}" != *"xterm"* ]] || [ -t 1 ]; then
            # Don't use colors on pipes or non-recognized terminals
            return 1
        else
            return 0
        fi
    }

    UI.Color.Print() {
        : @mixed colorCode
        @@verify

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[${colorCode}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    UI.Color.256text() {
        : @mixed colorNumber
        @@verify

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[38;5;${colorNumber}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    UI.Color.256background() {
        : @mixed colorNumber
        @@verify

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[48;5;${colorNumber}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    alias UI.Color.Default="UI.Color.Print '0'"

    alias UI.Color.Black="UI.Color.Print '0;30'"
    alias UI.Color.Red="UI.Color.Print '0;31'"
    alias UI.Color.Green="UI.Color.Print '0;32'"
    alias UI.Color.Yellow="UI.Color.Print '0;33'"
    alias UI.Color.Blue="UI.Color.Print '0;34'"
    alias UI.Color.Magenta="UI.Color.Print '0;35'"
    alias UI.Color.Cyan="UI.Color.Print '0;36'"
    alias UI.Color.LightGray="UI.Color.Print '0;37'"

    alias UI.Color.DarkGray="UI.Color.Print '0;90'"
    alias UI.Color.LightRed="UI.Color.Print '0;91'"
    alias UI.Color.LightGreen="UI.Color.Print '0;92'"
    alias UI.Color.LightYellow="UI.Color.Print '0;93'"
    alias UI.Color.LightBlue="UI.Color.Print '0;94'"
    alias UI.Color.LightMagenta="UI.Color.Print '0;95'"
    alias UI.Color.LightCyan="UI.Color.Print '0;96'"
    alias UI.Color.White="UI.Color.Print '0;97'"

    # flags
    alias UI.Color.Bold="UI.Color.Print '1'"
    alias UI.Color.Dim="UI.Color.Print '2'"
    alias UI.Color.Underline="UI.Color.Print '4'"
    alias UI.Color.Blink="UI.Color.Print '5'"
    alias UI.Color.Invert="UI.Color.Print '7'"
    alias UI.Color.Invisible="UI.Color.Print '8'"

    alias UI.Color.NoBold="UI.Color.Print '21'"
    alias UI.Color.NoDim="UI.Color.Print '22'"
    alias UI.Color.NoUnderline="UI.Color.Print '24'"
    alias UI.Color.NoBlink="UI.Color.Print '25'"
    alias UI.Color.NoInvert="UI.Color.Print '27'"
    alias UI.Color.NoInvisible="UI.Color.Print '28'"
    # regex:
    #UI.Color.Print '([\d]+[;]*[\d]*')
    #echo \\\\\\$'\\\\033[$1m'

#    alias UI.Color.Default="echo \$'\033[0'm'"
#
#    alias UI.Color.Black="echo \$'\033[0;30'm'"
#    alias UI.Color.Red="echo \$'\033[0;31'm'"
#    alias UI.Color.Green="echo \$'\033[0;32'm'"
#    alias UI.Color.Yellow="echo \$'\033[0;33'm'"
#    alias UI.Color.Blue="echo \$'\033[0;34'm'"
#    alias UI.Color.Magenta="echo \$'\033[0;35'm'"
#    alias UI.Color.Cyan="echo \$'\033[0;36'm'"
#    alias UI.Color.LightGray="echo \$'\033[0;37'm'"
#
#    alias UI.Color.DarkGray="echo \$'\033[0;90'm'"
#    alias UI.Color.LightRed="echo \$'\033[0;91'm'"
#    alias UI.Color.LightGreen="echo \$'\033[0;92'm'"
#    alias UI.Color.LightYellow="echo \$'\033[0;93'm'"
#    alias UI.Color.LightBlue="echo \$'\033[0;94'm'"
#    alias UI.Color.LightMagenta="echo \$'\033[0;95'm'"
#    alias UI.Color.LightCyan="echo \$'\033[0;96'm'"
#    alias UI.Color.White="echo \$'\033[0;97'm'"
#
#    # flags
#    alias UI.Color.Bold="echo \$'\033[1'm'"
#    alias UI.Color.Dim="echo \$'\033[2'm'"
#    alias UI.Color.Underline="echo \$'\033[4'm'"
#    alias UI.Color.Blink="echo \$'\033[5'm'"
#    alias UI.Color.Invert="echo \$'\033[7'm'"
#    alias UI.Color.Invisible="echo \$'\033[8'm'"
#
#    alias UI.Color.NoBold="echo \$'\033[21'm'"
#    alias UI.Color.NoDim="echo \$'\033[22'm'"
#    alias UI.Color.NoUnderline="echo \$'\033[24'm'"
#    alias UI.Color.NoBlink="echo \$'\033[25'm'"
#    alias UI.Color.NoInvert="echo \$'\033[27'm'"
#    alias UI.Color.NoInvisible="echo \$'\033[28'm'"

}
