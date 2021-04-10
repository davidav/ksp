@lazyglobal off.
    // public gAlt :: nothing -> float /gravity at this height/
    function gAlt{
        return (ship:body:mu/(body:radius + ship:altitude)^2).
}
