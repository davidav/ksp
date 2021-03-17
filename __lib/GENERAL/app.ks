//Устанавливаем цель
SET Target TO VESSEL("Craft1").

//Вектор на цель
LOCK TargetVector TO Target:ORBIT:POSITION-SHIP:ORBIT:POSITION.
//Вектор относительной скорости
LOCK RelativeVelocity TO SHIP:VELOCITY:ORBIT-Target:VELOCITY:ORBIT.

//Выполняем в цикле до сближения на 80м
UNTIL (TargetVector:MAG<80)
{
    //Скорость сближения должна быть примерно равна расстоянию / 20 
	SET DesiredVelocityVector TO TargetVector/20.
	//Но не более 100 м/с
	IF (DesiredVelocityVector:MAG>100)
	{
		SET DesiredVelocityVector TO DesiredVelocityVector:NORMALIZED*100.
	}
	//Коррекционный вектор, прицеливаемся вдоль него
	SET CorrectionVector TO DesiredVelocityVector - RelativeVelocity.
	LOCK STEERING TO CorrectionVector.
	// Если прицелились +- 5град, то прожиг
	IF (VANG(CorrectionVector,SHIP:FACING:FOREVECTOR)<5)
	{
		LOCK THROTTLE TO MIN(CorrectionVector:MAG/20,1).
	}
	ELSE
	{
		LOCK THROTTLE TO 0.
	}
	//выводим относ. скорость и расстояние на экран
	clearscreen.
	print "Approach Velocity: " + VDOT(RelativeVelocity,TargetVector:NORMALIZED).
	print "Target Distance: " + TargetVector:MAG.
}
//Если есть сближение на 80м
//выключаем тягу, прицеливаемся против вектора относительной скорости
//ждем 3 сек.
LOCK THROTTLE TO 0.
LOCK STEERING TO -RelativeVelocity.
WAIT 3.
//гасим относительную скорость почти в 0.
UNTIL (RelativeVelocity:MAG<0.01)
{
	LOCK THROTTLE TO MIN(RelativeVelocity:MAG/20,1).
}

//Сближение выполнено, гашение относительной скорости выполнено, можно переходить к стыковке
LOCK THROTTLE TO 0.
UNLOCK STEERING.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
clearscreen.
print "APPROACH COMPLETE.".






