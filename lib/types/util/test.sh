import ../ui/cursor

static:Test(){
    extends Object
    
    UI.Cursor OnStartCursor
    Boolean Errors = false
    String GroupName
    
    Test.Start() {
        @String verb
        @String description

        Test.OnStartCursor.Capture
        echo $(UI.Color.Yellow)$(UI.Powerline.PointingArrow) $(UI.Color.Yellow)[$(UI.Color.LightGray)$(UI.Color.Bold)TEST$(UI.Color.NoBold)$(UI.Color.Yellow)] $(UI.Color.White)${verb} ${description}$(UI.Color.Default)
    }
    
    Test.OK() {
        local printInPlace=${1:-true}
        #: @Boolean noPrintInPlace

        [[ $printInPlace = true ]] && Test.OnStartCursor.Restore
        echo $(UI.Color.Green)$(UI.Powerline.OK) $(UI.Color.Yellow)[ $(UI.Color.Green)$(UI.Color.Bold)OK$(UI.Color.NoBold) $(UI.Color.Yellow)]$(UI.Color.Default)
        return 0
    }

    Test.EchoedOK() {
        Test.OK false
    }
    
    Test.Fail() {
        #Test.OnStartCursor.Restore
        echo $(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Yellow)[$(UI.Color.Red)$(UI.Color.Bold)FAIL$(UI.Color.NoBold)$(UI.Color.Yellow)]$(UI.Color.Default)
    }

    Test.DisplaySummary() {
        if Test.Errors
        then
            echo "$(UI.Powerline.ArrowLeft) $(UI.Color.Magenta)Completed [$(Test.GroupName)]: $(UI.Color.Default)$(UI.Color.Red)There were errors $(UI.Color.Default)$(UI.Powerline.Lightning)"
            Test.Errors = false
        else
            echo "$(UI.Powerline.ArrowLeft) $(UI.Color.Magenta)Completed [$(Test.GroupName)]: $(UI.Color.Default)$(UI.Color.Yellow)Test group completed succesfully $(UI.Color.Default)$(UI.Powerline.ThumbsUp)"
            return 0
        fi
    }

    Test.NewGroup() {
        @var groupName
        
        echo "$(UI.Powerline.ArrowRight)" $(UI.Color.Magenta)Testing [$groupName]: $(UI.Color.Default)
        Test.GroupName = "$groupName"
    }
}

alias cought="echo \"COUGHT: $(UI.Color.Red)\$__BACKTRACE_COMMAND__$(UI.Color.Default) in \$__BACKTRACE_SOURCE__:\$__BACKTRACE_LINE__\""
alias it="Test.Start it"
alias expectPass="Test.OK; catch { Test.Errors = true; Test.Fail; }"
alias expectOutputPass="Test.EchoedOK; catch { Test.Errors = true; Test.Fail; }"
alias expectFail='catch { cought; Test.EchoedOK; }; test $? -eq 1 && Test.Errors = false; '
