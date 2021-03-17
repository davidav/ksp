switch to 1.
copypath("0:/OS/bootOS", "").
run bootOS.// boot OS
gui["loadingIndicator"]().
clearscreen.
print "SYSTEM OK!" at (5, 19).
sound["beepOK"]().
wait 1.
clearscreen.
OS_Boot["CopyAndRunFile"]("Vostok3").//start control program
wait 3.
sound["beepOK"]().