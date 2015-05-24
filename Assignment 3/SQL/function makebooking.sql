CREATE OR REPLACE FUNCTION carsharing.makebooking(username character varying, carname character varying, userstarttime timestamp without time zone, userendtime timestamp without time zone, duration integer)
  RETURNS record AS
$$

DECLARE
availability INT;
pricing RECORD;
registrationNumber VARCHAR;
memberID INT;
accountID INT;
planType VARCHAR;

BEGIN
SELECT regno INTO registrationNumber FROM Car WHERE name = carName;
SELECT memberno INTO memberId FROM Member WHERE nickname = userName;
SELECT accountNo INTO accountID FROM Member	WHERE nickname = userName;
SELECT plan INTO planType FROM Account WHERE accountNo = accountID;
SELECT COUNT(*) INTO availability 
	FROM Car C, Booking B
	WHERE C.name = carName AND C.regno = B.car AND B.status = 'active' AND 
	((B.starttime BETWEEN userstarttime AND userstarttime + duration * INTERVAL '1 hours' OR B.endtime BETWEEN userstarttime AND userstarttime + duration * INTERVAL '1 hours')
	OR (Booking.starttime >= userstarttime AND Booking.starttime <= userendtime)
	OR (Booking.endtime >= userstarttime AND Booking.endtime <= userendtime)
	OR (Booking.starttime >= userstarttime AND Booking.endtime <= userendtime));

IF (availability = 0 AND userstarttime >= CURRENT_TIMESTAMP) THEN
	
	INSERT INTO BOOKING (car, madeby, status, starttime, endtime)
	VALUES ( registrationNumber, memberId, 'active', userstarttime, userstarttime + duration * INTERVAL '1 hours');

	UPDATE Memberstats
	SET stat_nrofbookings = stat_nrofbookings + 1
	WHERE memberno = memberID;

	IF(duration >= 12) THEN
		SELECT B.id, C.name, B.starttime, B.endtime, B.status, P.name, P.addr, MP.daily_rate INTO pricing
		FROM Booking B, Car C, Pod P, MembershipPlan MP 
		WHERE C.name = carName AND B.starttime = start AND P.id = C.parkedat AND MP.title = planType;
	RETURN pricing;

	ELSEIF (duration < 12) THEN
		SELECT B.id, C.name, B.starttime, B.endtime, B.status, P.name, P.addr, MP.hourly_rate * duration INTO pricing
		FROM Booking B, Car C, Pod P, MembershipPlan MP 
		WHERE C.name = carName AND B.starttime = start AND P.id = C.parkedat AND MP.title = planType;
	RETURN pricing;

END IF;
ELSE
RETURN Null;
END IF;
END;
$$
  LANGUAGE plpgsql