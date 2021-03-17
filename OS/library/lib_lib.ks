@lazyglobal off.
    // public gAlt :: nothing -> float /gravity at this height/
    function gAlt{
        return (ship:body:mu/(ship:body:radius + altitude)^2).
}
