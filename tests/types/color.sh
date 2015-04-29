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

    String Default = "$(UI.Color.Print '0')"

    String Black = "$(UI.Color.Print '0;30')"
    String Red = "$(UI.Color.Print '0;31')"
    String Green = "$(UI.Color.Print '0;32')"
    String Yellow = "$(UI.Color.Print '0;33')"
    String Blue = "$(UI.Color.Print '0;34')"
    String Magenta = "$(UI.Color.Print '0;35')"
    String Cyan = "$(UI.Color.Print '0;36')"
    String LightGray = "$(UI.Color.Print '0;37')"

    String DarkGray = "$(UI.Color.Print '0;90')"
    String LightRed = "$(UI.Color.Print '0;91')"
    String LightGreen = "$(UI.Color.Print '0;92')"
    String LightYellow = "$(UI.Color.Print '0;93')"
    String LightBlue = "$(UI.Color.Print '0;94')"
    String LightMagenta = "$(UI.Color.Print '0;95')"
    String LightCyan = "$(UI.Color.Print '0;96')"
    String White = "$(UI.Color.Print '0;97')"

    # flags
    String Bold = "$(UI.Color.Print '1')"
    String Dim = "$(UI.Color.Print '2')"
    String Underline = "$(UI.Color.Print '4')"
    String Blink = "$(UI.Color.Print '5')"
    String Invert = "$(UI.Color.Print '7')"
    String Invisible = "$(UI.Color.Print '8')"

    String NoBold = "$(UI.Color.Print '21')"
    String NoDim = "$(UI.Color.Print '22')"
    String NoUnderline = "$(UI.Color.Print '24')"
    String NoBlink = "$(UI.Color.Print '25')"
    String NoInvert = "$(UI.Color.Print '27')"
    String NoInvisible = "$(UI.Color.Print '28')"

} && oo:enableType

echo $(UI.Color.Red)Red $(UI.Color.256text 213)here$(UI.Color.Default) Boom
