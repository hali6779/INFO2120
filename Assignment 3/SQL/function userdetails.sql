/* Stored function to retrieve details of user */
CREATE OR REPLACE FUNCTION get_user_details ( username VARCHAR ) RETURNS TABLE (nbookings int, memno int, givenname text, familyname text, address text, podId int, podname text) AS $$
BEGIN
SELECT memberstats.stat_nrOfBookings, member.memberNo, member.givenName, member.familyName, member.address, member.homePod, pod.name INTO nbookings, memno, givenname, familyname, address, podId, podname
        FROM CarSharing.Member 
        LEFT OUTER JOIN CarSharing.MemberStats on Member.memberNo = MemberStats.memberNo
        LEFT OUTER JOIN CarSharing.pod on Member.homepod = pod.id
        WHERE nickName=username;
        RETURN NEXT;
        RETURN;
END;
	$$ language 'plpgsql';

