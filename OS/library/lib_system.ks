//@lazyglobal off.
// public class systemController     
function systemController{  
    // public displayNameCyclogram :: text ->           
    function displayNameCyclogram{
        parameter nameCyclogram is "".
        clearscreen.
        print "PROGRAMM: "+nameProgram at(5,1).
        print "CYCLOGRAM: "+nameCyclogram at(5,2).
    }
    // public openTerminal :: int -> int -> int ->    
    function openTerminal{
        parameter terminalWidth is 60.
        parameter terminalHeigth is 40.
        parameter fontHeight is 14.
        CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
        SET TERMINAL:WIDTH TO terminalWidth.
        SET TERMINAL:HEIGHT TO terminalHeigth.
        SET TERMINAL:CHARHEIGHT TO fontHeight.            
        clearscreen.
    }
    // public timer :: int -> text -> bool -> bool  
    function timer{
        parameter requestTime is 1.     
        parameter labelTimer is "wait: ".     
        parameter showTimer is 0.
        parameter soundTimer is 1.
        until requestTime = 0 {
            wait 1.
            set requestTime to requestTime - 1.
            if showTimer {
                print labelTimer + requestTime + " s" at (5, 19).
            }
            if soundTimer and requestTime = 1 {
                sound["timeIsOver"]().
            }
        }
    }
    // Return Public Fields
    return lexicon(
        "displayNameCyclogram", displayNameCyclogram@,
        "openTerminal", openTerminal@,        
        "timer", timer@
    ).        
}
global system is systemController().