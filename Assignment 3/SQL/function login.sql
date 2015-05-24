/* Stored function to check login of user */
CREATE OR REPLACE FUNCTION login ( username VARCHAR, pword VARCHAR ) RETURNS BIGINT AS $$ 
	BEGIN
		RETURN (SELECT COUNT(*) FROM carsharing.member
		WHERE nickname=username AND passwd=pword);
	END
	$$ language 'plpgsql';
