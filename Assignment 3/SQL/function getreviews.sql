
CREATE OR REPLACE FUNCTION get_Reviews(review_id INT) RETURNS TABLE(mname VARCHAR, whendone TIMESTAMP, test TEXT)
	BEGIN
		RETURN QUERY(SELECT reviewMem, whendone, rating, description 
			FROM carsharing.review WHERE review.memberno = member.memberno AND review.regno = car.regno);
		END
		$$ language 'plpgsql';
