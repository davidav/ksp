set volume(1):name to "sat1".
if status="PRELAUNCH" { 
  copypath("0:/KommSat.ks","satprogram.ks").
  log "local satmode to 0." to "mode.ks".
}
runpath("mode.ks").
runpath("satprogram.ks").
satprogram().
