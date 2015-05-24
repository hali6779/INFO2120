CREATE OR REPLACE FUNCTION carsharing.getHomePod(username text) RETURNS SETOF RECORD AS $$


DECLARE podName text;

BEGIN
	RETURN QUERY SELECT name
        FROM CarSharing.Member JOIN CarSharing.Pod on Member.homePod = Pod.id
        WHERE nickname=username;
END;
$$ LANGUAGE plpgsql;