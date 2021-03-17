clearscreen.
switch to 1.
copypath("0:/OS/bootOS", "").
run bootOS.// boot OS
gui["loadingIndicator"](15, "x").//name control program
clearscreen.
print "SYSTEM OK!" at (5, 19).
sound["timeIsOver"]().
wait 1.
clearscreen.
OS_Boot["copyAndRunFile"]("x").//name control program
sound["beepOK"]().
