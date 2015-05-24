CREATE OR REPLACE FUNCTION getBookings(username text) RETURNS SETOF RECORD AS $$


DECLARE result RECORD;

BEGIN
	 RETURN QUERY SELECT Booking.id, Car.name, Car.regno, Booking.whenbooked, Booking.starttime::date, Booking.starttime::time, Booking.endtime::date, Booking.endtime::time
         FROM CarSharing.Booking 
         INNER JOIN CarSharing.Member on member.memberno=booking.madeby
         INNER JOIN CarSharing.Car on Car.regno=Booking.car
         WHERE member.nickname=username AND Booking.status='active' ORDER BY Booking.whenbooked DESC;
         

END;
$$ LANGUAGE plpgsql;

