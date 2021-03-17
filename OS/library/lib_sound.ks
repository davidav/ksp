//@lazyglobal off.
// public class soundController     
function soundController{
    
    function beepOK {
        local V0 TO GetVoice(0).
        V0:PLAY(
            LIST(
                NOTE("c4", 0.1,  0.25), 
                NOTE("e4",  0.1,  0.25), 
                NOTE("g4",  0.1,  0.25), 
                NOTE("c5",  0.3,  0.25)
            )
        ).
    }
    function timeIsOver {
        local V0 TO GetVoice(0).
        V0:PLAY(
            LIST(
                NOTE("c4", 0.1,  0.25), 
                NOTE("r", 0.1,  0.25), 
                NOTE("c5", 0.1,  0.25) 
            )
        ).
    }
    function link {
        local V0 TO GetVoice(0).
        V0:PLAY(
            LIST(
                NOTE("c4", 0.1,  0.25), 
                NOTE("r", 0.1,  0.25), 
                NOTE("c4", 0.1,  0.25), 
                NOTE("r", 0.1,  0.25), 
                NOTE("c4", 0.1,  0.25)
            )
        ).
    }
    // Return Public Fields
    return lexicon(
        "beepOK", beepOK@,
        "link", link@,
        "timeIsOver", timeIsOver@
    ).  
}
global sound is soundController().