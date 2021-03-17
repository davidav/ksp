//Устанавливаем цель
SET Target TO VESSEL("Craft1").
//Устанавливаем стыковочные порты целевого и нашего корабля.
//Здесь просто самый первый порт, но можно искать их по индексу или по тагу.
SET TargetPort TO Target:DOCKINGPORTS[0].
SET MyPort TO SHIP:DOCKINGPORTS[0].
//Прицельный вектор - на порт корабля-цели
LOCK TargetVector TO TargetPort:POSITION-MyPort:POSITION.
LOCK STEERING TO LOOKDIRUP(TargetVector, TargetPort:FACING:UPVECTOR).
WAIT 10.
UNLOCK STEERING.

//включаем RCS, инициализируем пидлупы для RCS
RCS ON.
SET STARPID TO PIDLOOP(0.1, 0, 1).
SET TOPPID TO PIDLOOP(0.1, 0, 1).
SET FOREPID TO PIDLOOP(0.3, 0, 3).

//выполняем этот цикл до момента стыковки
UNTIL (MyPort:STATE:CONTAINS("Docked"))
{

	//Это вектора вперед, вправо и вверх стыковочного порта корабля-цели
	SET DockingFORE TO TargetPort:FACING:FOREVECTOR.
	SET DockingTOP TO TargetPort:FACING:UPVECTOR.
	SET DockingSTAR TO TargetPort:FACING:STARVECTOR.
	
	//Вектор прицеливания нашим портом ставим на 3 м за порт цели.
	SET TargetVector TO TargetPort:POSITION-MyPort:POSITION-DockingFORE*3.
	//Смотрим портом на целевой порт, вектора вверх обоих портов подкручиваем до максимального совмещения.
	SET STEERING TO LOOKDIRUP(TargetVector, DockingTOP).

	// Считаем проекции таргетвектора на оси порта корабля-цели. 
	SET TopProjection TO VDOT(-TargetVector:NORMALIZED, DockingTOP).
	SET STARProjection TO VDOT(-TargetVector:NORMALIZED, DockingSTAR).
	SET FOREProjection TO VDOT(-TargetVector:NORMALIZED, DockingFORE).
    
	//Считаем ветрикальный и горизонтальный углы отклонения от центральной оси порта корабля-цели
	SET TopAngle TO ARCTAN2(TopProjection, FOREProjection).
	SET StarAngle TO ARCTAN2(STARProjection, FOREProjection).
	
	//Шаманство с пид-регуляторами на случай старта стыковки из задней полусферы порта станции
	IF (ABS(TopAngle)>90)
	{
		SET TOPPID:KP TO 0.	
		SET TOPPID:KD TO -1.	
	}
	ELSE
	{
		SET TOPPID:KP TO 0.1.
		SET TOPPID:KD TO 1.	
	}
	
	IF (ABS(StarAngle)>90)
	{
		SET STARPID:KD TO 10.	
	}
	ELSE
	{
		SET STARPID:KD TO 1.
	}	
	
	IF (TargetVector:MAG>50)
	{
		SET STARPID:KP TO 0.	
		SET TOPPID:KP TO 0.
	}
	ELSE
	{
		SET STARPID:KP TO 0.1.	
		SET TOPPID:KP TO 0.1.
	}		
		
	//Связываем RCS с углами отклонения через пидлуп.
	SET SHIP:CONTROL:TOP TO TOPPID:UPDATE(TIME:SECONDS, TopAngle).
	SET SHIP:CONTROL:STARBOARD TO STARPID:UPDATE(TIME:SECONDS, -StarAngle).

	//Если углы отклонения менее 3 градусов, то идем на стыковку
	//Если более - стараемся держать расстояние около 30 м.
	IF (ABS(TopAngle)<3) AND (ABS(StarAngle)<3)
	{
		SET SHIP:CONTROL:FORE TO FOREPID:UPDATE(TIME:SECONDS, -(TargetVector:MAG)).
	}
	ELSE
	{
		SET SHIP:CONTROL:FORE TO FOREPID:UPDATE(TIME:SECONDS, (30-TargetVector:MAG)).
	}
	//Выводим инфу на экран
	clearscreen.
	print "TopAngle: " + TopAngle.
	print "StarAngle: " + StarAngle.	
	print "TOP: " + SHIP:CONTROL:TOP.	
	print "STARBOARD: " + SHIP:CONTROL:STARBOARD.
}

//В результате этого цикла стыковка должна быть завершена.
UNLOCK STEERING.
SET SHIP:CONTROL:TOP TO 0.
SET SHIP:CONTROL:STARBOARD TO 0.
SET SHIP:CONTROL:FORE TO 0.
RCS OFF.
clearscreen.
print "SHIP DOCKED".