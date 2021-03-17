// @lazyglobal off.
{
  global OS_Boot is lexicon(
    "copyAndRunFile", copyAndRunFile@,
    "copyFile", copyFile@
    ).

      Function copyAndRunFile {
        parameter targetFile.
        parameter fileLocation is "0:/".
        local string1 to fileLocation + targetFile.
        copypath(string1, "").
        runpath(targetFile).
      }

      Function copyFile {
        parameter targetFile.
        parameter fileLocation is "0:/".
        local string1 to fileLocation + targetFile.
        copypath(string1, "").
      }
}
OS_Boot["copyAndRunFile"]("lib_const", "0:/OS/library/").      
OS_Boot["copyAndRunFile"]("lib_lib", "0:/OS/library/").      
OS_Boot["copyAndRunFile"]("lib_gui", "0:/OS/library/").
OS_Boot["copyAndRunFile"]("lib_sound", "0:/OS/library/").
OS_Boot["copyAndRunFile"]("lib_system", "0:/OS/library/").
OS_Boot["copyAndRunFile"]("lib_vessel", "0:/OS/library/").
OS_Boot["copyAndRunFile"]("lib_maneuvers", "0:/OS/library/").
// OS_Boot["copyAndRunFile"]("landingDataModel", "0:/OS/models/").
// OS_Boot["copyAndRunFile"]("hoverSlamModel", "0:/OS/models/").
// OS_Boot["copyAndRunFile"]("glideController", "0:/OS/controllers/").
// OS_Boot["copyAndRunFile"]("landingController", "0:/OS/controllers/").
system["openTerminal"](). 
// switch to 0.