//@lazyglobal off.
// public class guiController
function guiController{
    // loadingIndicator :: int -> int -> Indicator
    function loadingIndicator{
        parameter duration is 10.
        parameter labelIndicator is "LOADING ".
        local symbolSignal is "O".
        local symbolEmpty is "-".
        local indicatorSignal to "".
        local indicatorEmpty to "".
        local indicator to indicatorEmpty.
        until duration < -1 {
            wait 0.05.
            set indicatorSignal to indicatorSignal + symbolSignal.
            local invertDuration to 0.
            set indicatorEmpty to "".
            until invertDuration > duration {
                set indicatorEmpty to indicatorEmpty + symbolEmpty.
                set invertDuration to invertDuration + 1.
            }
            set indicator to indicatorSignal + indicatorEmpty.
            print labelIndicator + indicator at (5, 19).
            set duration to duration - 1.
        }
    }
    //     function notify :: text -> text -> int -> int -> int -> bool-> Indicator
    function notify{
    	parameter nMsg.
    	parameter nCol is yellow.
    	parameter nDly is 5.
    	parameter nSty is 2.
    	parameter nSz is 20.
    	parameter nEcho is false.
    	hudtext(nMsg,nDly,nSty,nSz,nCol,nEcho).
    }
    // Return Public Fields
    return lexicon(
        "loadingIndicator", loadingIndicator@,
        "notify", notify@
    ).
}
global gui is guiController().
