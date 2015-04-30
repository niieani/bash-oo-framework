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
        @mixed colorCode
        @@verify "$@"

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[${colorCode}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    UI.Color.256text() {
        @mixed colorNumber
        @@verify "$@"

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[38;5;${colorNumber}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    UI.Color.256background() {
        @mixed colorNumber
        @@verify "$@"

        if UI.Color.IsAvailable
        then
            local colorString="\$'\033[48;5;${colorNumber}m'"
            eval echo "${colorString}"
        else
            echo
        fi
    }

    Const Default = "$(UI.Color.Print '0')"

    Const Black = "$(UI.Color.Print '0;30')"
    Const Red = "$(UI.Color.Print '0;31')"
    Const Green = "$(UI.Color.Print '0;32')"
    Const Yellow = "$(UI.Color.Print '0;33')"
    Const Blue = "$(UI.Color.Print '0;34')"
    Const Magenta = "$(UI.Color.Print '0;35')"
    Const Cyan = "$(UI.Color.Print '0;36')"
    Const LightGray = "$(UI.Color.Print '0;37')"

    Const DarkGray = "$(UI.Color.Print '0;90')"
    Const LightRed = "$(UI.Color.Print '0;91')"
    Const LightGreen = "$(UI.Color.Print '0;92')"
    Const LightYellow = "$(UI.Color.Print '0;93')"
    Const LightBlue = "$(UI.Color.Print '0;94')"
    Const LightMagenta = "$(UI.Color.Print '0;95')"
    Const LightCyan = "$(UI.Color.Print '0;96')"
    Const White = "$(UI.Color.Print '0;97')"

    # flags
    Const Bold = "$(UI.Color.Print '1')"
    Const Dim = "$(UI.Color.Print '2')"
    Const Underline = "$(UI.Color.Print '4')"
    Const Blink = "$(UI.Color.Print '5')"
    Const Invert = "$(UI.Color.Print '7')"
    Const Invisible = "$(UI.Color.Print '8')"

    Const NoBold = "$(UI.Color.Print '21')"
    Const NoDim = "$(UI.Color.Print '22')"
    Const NoUnderline = "$(UI.Color.Print '24')"
    Const NoBlink = "$(UI.Color.Print '25')"
    Const NoInvert = "$(UI.Color.Print '27')"
    Const NoInvisible = "$(UI.Color.Print '28')"

} && oo:enableType
