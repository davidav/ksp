switch to 1.
copypath("0:/OS/bootOS", "").
run bootOS.
gui["loadingIndicator"]().
clearscreen.
print "SYSTEM OK!" at (5, 19).
sound["beepOK"]().
wait 1.
clearscreen.
OS_Boot["CopyAndRunFile"]("T1_01").//start control program
wait 3.
sound["beepOK"]().
