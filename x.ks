



vessel["actModule"]("SeviceBay.125.v2", "Open").

print "serviceBay OK!" at (5, 19).
gui["loadingIndicator"](15, "x").
wait 5.


// CLEARSCREEN.
// set heigthVessel to alt:radar.
// set targetAlt to altitude + 300.
// stage.
// set quantityFuel to STAGE:LIQUIDFUEL.
// wait 0.1.
// until FALSE {
//     if STAGE:LIQUIDFUEL > quantityFuel*0.6  {
//         set controlVectorResult to (controlVesselStabilizing()).
//         if (controlVectorResult:mag > 0.25){
//             set controlVectorResult to controlVectorResult:normalized*0.25.
//         }
//         lock steering to lookDirUp(controlVectorResult, controlVesselROll()).
//         lock throttle to keepAlt(controlVesselAlt(targetAlt)).
//                 print "control "+ship:status at(5,5).
//     }else{
//         gear on.
//         if alt:radar > heigthVessel + 10{
//             lock steering to lookDirUp(controlVesselStabilizing(), ship:facing:topvector).
//             lock throttle to keepAlt(heigthVessel, "Radar").
//                 print "Stabilizing "+ship:status at(5,5).
//         }else{
//             lock steering to heading(90,90).
//             lock throttle to keepVerticalSpeed(-1).
//                 print "Landing "+ship:status at(5,5).
//             if ship:status = "LANDED" {
//                 set throttle to 0.
//                 break.
//             }
//         }
//     }
// }
// print "landed".

//public controlVesselStabilizing :: nothing -> vector
// function controlVesselStabilizing{
//     //горизонтальная состовляющая скорости
//     set horizontalSpeedVector to vxcl(ship:up:vector, ship:orbit:velocity:surface).
//     //стабилизирующий вектор к гориз состовляющей с дэмпфирующим коэффициентом
//     set stabilizingVector to (-horizontalSpeedVector * 0.1).
//     //ограничеваем наклон
//     if (stabilizingVector:mag > 0.25){
//         set stabilizingVector to stabilizingVector:normalized*0.25.
//     }
//     //возвращаем стабилизирующий вектор
//     return stabilizingVector.
// }
// //public controlVesselPitch :: int -> vector
// function controlVesselPitch{
//     parameter kInput is 3.
//     //управление по тангажу
//     //взяли проекцию вектора направления люка кабины на гориз. пл-ть, нормализовали, умножили на ввод от пилота (w,s)
//     set pitchVector to vxcl(ship:up:vector, ship:facing:topvector):normalized * ship:control:pilotpitch*kInput.
//     //ограничеваем наклон
//     // if (pitchVector:mag > 0.25){
//     //     set pitchVector to pitchVector:normalized*0.25.
//     // }
//     //возвращаем суммарный Pitch вектор направления с учетом команд управления
//     return pitchVector.
// }
// //public controlVesselYaw :: int -> vector
// function controlVesselYaw{
//     parameter kInput is 3.
//     //управление по рысканью (d,a)
//     set yawVector to vxcl(ship:up:vector, ship:facing:rightvector):normalized * ship:control:pilotyaw*kInput.
//     //ограничеваем наклон
//     // if (yawVector:mag > 0.25){
//     //     set yawVector to yawVector:normalized*0.25.
//     // }
//     //возвращаем суммарный Yaw вектор направления с учетом команд управления
//     return yawVector.
// }
// //public controlVesselRoll :: int -> vector
// function controlVesselROll{
//     parameter kInput is 3.
//     // проекция вектора направления двери кабины(facing:topvector) на землю
//     // (плоскость перпендикулярная направлению "вверх" (up:vector))
//     // vxcl - исключает все up из facing
//     set topVector to vxcl(ship:up:vector, ship:facing:topvector):normalized.
//     //управление по крену
//     //vcrs - векторное произведение вектора вверх и проекции направления двери кабины на землю
//     //дает перпендкулярный вектор в сторону, который и умножили на ввод от пилота (q,e)
//     set topVector to topVector + vcrs(ship:up:vector, topVector):normalized*ship:control:pilotroll*kInput.
//         //возвращаем вектор направления по крену с учетом команд управления
//     return topVector.
// }
// //public controlVesselAlt :: int -> int -> float
// function controlVesselAlt{
//     parameter tarAlt.
//     parameter kInput is 3.
//         //управление высотой полета (i k)
//     set tarAlt to tarAlt + ship:control:pilottop*kInput.
//         //возвращаем высоту с учетом команд управления
//     return tarAlt.
// }
// //public keepVerticalSpeed :: int,"Radar", float, float -> required thrust
// function keepAlt{
//     parameter targetA.
//     parameter altRelative is "".
//     parameter kSpeed is 0.3.

//     if altRelative = "Radar" {
//         //diffAlt - разница высот между требуемой и дествительной
//         set diffAlt to targetA - alt:radar.
//     }else{
//         set diffAlt to targetA - altitude.
//     }
//     return keepVerticalSpeed(diffAlt*kSpeed).
// }
// //public keepVerticalSpeed :: int, float -> required throttle
// function keepVerticalSpeed{
//     parameter targetSpeed.
//     parameter kAcceleration is 2.
//         //diffSpeeds - разница скоростей между требуемой и дествительной
//     set diffSpeeds to targetSpeed - ship:verticalspeed.
//     set diffAcceleration to diffSpeeds*kAcceleration.
//         // gAlt - сила тяжести на данной высоте
//     // set gAlt to ship:body:mu/(ship:body:radius + altitude)^2.
//         // throttleRequired тяга для набора и удерживания требуемой высоты
//         // с помощью скалярного произведения (vdot) единичных векторов получаем cos угла между ними
//         // те самым увеличивает тягу в зависимости от отклонения корабля для компенсации силы притяжения
//     set throttleRequired to (gAlt+diffAcceleration)*ship:mass/vdot(ship:up:vector, ship:facing:forevector).
//         // возвращаем тягу в частях от максимальной активной тяги
//     return throttleRequired/ship:maxthrust.
// }
