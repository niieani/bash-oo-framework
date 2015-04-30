static:Test() {
    extends Object
    
    UI.Cursor OnStartCursor
    UI.Cursor OnEndCursor
    
    Test.Start()
    {
        @String description
        @@verify
        
        Test.OnStartCursor.Capture
        echo $(UI.Color.Yellow)$(UI.Powerline.PointingArrow) $(UI.Color.Yellow)[$(UI.Color.LightGray)$(UI.Color.Bold)TEST$(UI.Color.NoBold)$(UI.Color.Yellow)] $(UI.Color.White)It ${description}$(UI.Color.Default)
    }
    
    Test.OK()
    {
        #Test.OnEndCursor.Capture
        Test.OnStartCursor.Restore
        echo $(UI.Color.Green)$(UI.Powerline.OK) $(UI.Color.Yellow)[ $(UI.Color.Green)$(UI.Color.Bold)OK$(UI.Color.NoBold) $(UI.Color.Yellow)]$(UI.Color.Default)
        #Test.OnEndCursor.Restore
    }
    
    Test.Fail()
    {
        #Test.OnEndCursor.Capture
        Test.OnStartCursor.Restore
        echo $(UI.Color.Red)$(UI.Powerline.Fail) $(UI.Color.Yellow)[$(UI.Color.Red)$(UI.Color.Bold)FAIL$(UI.Color.NoBold)$(UI.Color.Yellow)]$(UI.Color.Default)
        #Test.OnEndCursor.Restore
    }

} && oo:enableType

alias it="Test.Start"
alias finish="Test.OK; catch Test.Fail" 

