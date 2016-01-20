class:StaticTest(){

    private UI.Cursor onStartCursor
    private string errors
    private string groupName

    StaticTest.start() {
        @resolve:this
        [string] verb
        [string] description

        this onStartCursor capture
        echo "$(UI.Color.Yellow)$(UI.Powerline.PointingArrow) $(UI.Color.Yellow)[$(UI.Color.LightGray)$(UI.Color.Bold)TEST$(UI.Color.NoBold)$(UI.Color.Yellow)] $(UI.Color.White)${verb} ${description}$(UI.Color.Default)"
        @return
    }

    StaticTest.OK() {
        @resolve:this
        [string] printInPlace=true

        [[ $printInPlace == true ]] && this onStartCursor restore

        echo "$(UI.Color.Green)$(UI.Powerline.OK) $(UI.Color.Yellow)[ $(UI.Color.Green)$(UI.Color.Bold)OK$(UI.Color.NoBold) $(UI.Color.Yellow)]$(UI.Color.Default)"
        @return
    }

    StaticTest.echoedOK() {
        @resolve:this
        this OK false
    }

    StaticTest.fail() {
        @resolve:this
        #Test.OnStartCursor.Restore
        echo "$(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Yellow)[$(UI.Color.Red)$(UI.Color.Bold)FAIL$(UI.Color.NoBold)$(UI.Color.Yellow)]$(UI.Color.Default)"
        @return
    }

    StaticTest.displaySummary() {
        @resolve:this
        if [[ $(this errors) == true ]]
        then
          echo "$(UI.Powerline.ArrowLeft) $(UI.Color.Magenta)Completed [$(Test groupName)]: $(UI.Color.Default)$(UI.Color.Red)There were errors $(UI.Color.Default)$(UI.Powerline.Lightning)"
          this errors = false
        else
          echo "$(UI.Powerline.ArrowLeft) $(UI.Color.Magenta)Completed [$(Test groupName)]: $(UI.Color.Default)$(UI.Color.Yellow)Test group completed succesfully $(UI.Color.Default)$(UI.Powerline.ThumbsUp)"
        fi
        @return
    }

    StaticTest.newGroup() {
        @resolve:this
        [string] groupName

        echo "$(UI.Powerline.ArrowRight)" $(UI.Color.Magenta)Testing [$groupName]: $(UI.Color.Default)

        this groupName = "$groupName"

        @return
    }
}

Type::Initialize StaticTest

### TODO: special case for static classes
### for storage use a generated variable name (hash of class name?)
### for execution use class' name, e.g. StaticTest Start

StaticTest Test

alias caught="echo \"CAUGHT: $(UI.Color.Red)\$__BACKTRACE_COMMAND__$(UI.Color.Default) in \$__BACKTRACE_SOURCE__:\$__BACKTRACE_LINE__\""
alias it="Test start it"
alias expectPass="Test OK; catch { Test errors = true; Test fail; }"
alias expectOutputPass="Test echoedOK; catch { Test errors = true; Test fail; }"
alias expectFail='catch { caught; Test echoedOK; }; test $? -eq 1 && Test errors = false; '
