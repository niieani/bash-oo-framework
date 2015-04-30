static:Test() {
    extends Object
    
    public UICursor OnStartCursor
    public UICursor OnEndCursor
    
    Test.Start()
    {
        @String description
        @@verify
        
        Test.OnStartCursor.Capture
        echo $(UI.Color.Yellow)$(UI.Powerline.PointingArrow) [TEST] $(UI.Color.White)It ${description}$(UI.Color.Default)
    }
    
    Test.OK()
    {
        Test.OnEndCursor.Capture
        Test.OnStartCursor.Restore
        echo $(UI.Color.Green)  [ $(UI.Color.Bold)OK$(UI.Color.NoBold) ]$(UI.Color.Default)
        Test.OnEndCursor.Restore
    }
    
    Test.Fail()
    {
        Test.OnEndCursor.Capture
        Test.OnStartCursor.Restore
        echo $(UI.Color.Red) [FAIL]$(UI.Color.Default)
        Test.OnEndCursor.Restore
    }

} && oo:enableType

alias it="Test.Start"
alias finish="Test.OK; catch Test.Fail; echo" 

