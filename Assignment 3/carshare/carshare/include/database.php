<?php
/**
 * Database functions. You need to modify each of these to interact with the database and return appropriate results. 
 */

/**
 * Connect to database
 * This function does not need to be edited - just update config.ini with your own 
 * database connection details. 
 * @param string $file Location of configuration data
 * @return PDO database object
 * @throws exception
 */
function connect($file = 'config.ini') {
	// read database seetings from config file
    if ( !$settings = parse_ini_file($file, TRUE) ) 
        throw new exception('Unable to open ' . $file);
    
    // parse contents of config.ini
    $dns = $settings['database']['driver'] . ':' .
            'host=' . $settings['database']['host'] .
            ((!empty($settings['database']['port'])) ? (';port=' . $settings['database']['port']) : '') .
            ';dbname=' . $settings['database']['schema'];
    $user= $settings['db_user']['username'];
    $pw  = $settings['db_user']['password'];

	// create new database connection
    try {
        $dbh=new PDO($dns, $user, $pw);
        $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        print "Error Connecting to Database: " . $e->getMessage() . "<br/>";
        die();
    }
    return $dbh;
}

/**
 * Check login details
 * @param string $name Login name
 * @param string $pass Password
 * @return boolean True is login details are correct
 */
function checkLogin($name,$pass) {
	$db = connect();
	
	try {
	// stored procedure for safety
	$stmt = $db ->prepare('SELECT * FROM login(:nickname, :passwd)');
	
	
	$stmt -> bindValue(':nickname', $name, PDO::PARAM_STR);
	$stmt -> bindValue(':passwd', $pass, PDO::PARAM_STR);
	$stmt -> execute();
	$result = $stmt -> fetchColumn();
	$stmt -> closeCursor();
	
	} catch (PDOException $e) {
	
	print "Error checking login! " . $e->getMessage();
	return false;
	}
	return ($result ==1);

}

/**
 * Get details of the current user
 * @param string $user login name user
 * @return array Details of user - see index.php
 */
function getUserDetails($user) {

    $db = connect();
    try {
       $stmt = $db-> prepare('SELECT * FROM get_user_details(:user)');
       // call stored procedure get_user_details
       $stmt -> bindValue(':user', $user, PDO::PARAM_INT);
       // bind values
       $stmt -> execute();
       $results = $stmt -> fetch();
       //store array of details into variable "results"

       $stmt -> closeCursor();


	} catch (PDOException $e) {
		print "Error getting user details! ". $e -> getMessage();
		die();
	}
		
    return $results;
    //return the stored array of details from "results"
}

/** // non-stored procedure for getting user details
*function getUserDetails($user) {
*    $db = connect();
*	$results = array();
*    try {
*      $stmt = $db->prepare('SELECT * FROM carsharing.member WHERE nickname = :user');
*		$stmt -> bindValue(':user', $user, PDO::PARAM_STR);
*		$stmt -> execute(); 
*		while ($row = $stmt -> fetch()) {
*		$name = $row['title'] . "\t" . $row['givenname'] . "\t" . $row['familyname']. "\n";
*		$addr = $row['address'] . "\n";
*		}
*		
*		$stmt = $db -> prepare('SELECT p.name FROM carsharing.pod p, carsharing.member m WHERE
*		m.nickname = :user AND p.id = homepod');
*		$stmt -> bindValue(':user', $user, PDO::PARAM_STR);
*		$stmt -> execute();
*		$results['homepod'] = $stmt -> fetchColumn();
*		$stmt = $db -> prepare('SELECT s.stat_nrofbookings  FROM carsharing.memberstats s, carsharing.member m
*		WHERE m.nickname = :user AND s.memberno = m.memberno');
*		$stmt -> bindValue(':user', $user, PDO::PARAM_STR);
*		$stmt -> execute();
*		$results['nbookings'] = $stmt -> fetchColumn();
*		$stmt->closeCursor();  
*	} catch (PDOException $e) {
*		print "Error getting user details!";
*	}
*	$results['name'] = $name;
*	$results['address'] = $addr;
*		
*   return $results;
*}
*
*/


/**
 * Get details of the current user
 * @param string $user ID of member
 * @return Name of user's home pod, or null if no home pod exists - see homepod.php
 */
function getHomePod($user) {

	$db = connect();
				try{
		$stmt = $db -> prepare('SELECT * FROM carsharing.getHomePod(:user) t(name varchar)');
		$stmt->bindValue(':user', $user, PDO::PARAM_INT);
		$stmt->execute();
		$results = $stmt->fetchColumn();
		$stmt->closeCursor();
		}catch (PDOException $e){
			print "Error getting homepod: " . $e->getMessage();
			die();
		}
		return $results;
	
}

/** - basic getPod method without ordering
*function getPodCars($pod) {
*	// Return no cars if no pod specified
*	$db = connect();
*   $results = array();
*	try{
*		$stmt = $db->prepare('SELECT car.name, year as year, transmission as transmission, booking.status as avail
*							 
*							  FROM carsharing.pod JOIN carsharing.car ON (pod.id = Car.parkedAt)
*							  JOIN BOOKING ON (Booking.car = car.regno)
*							  WHERE  pod.name=? ');
*		$stmt -> bindValue(1, $pod, PDO::PARAM_STR);
*		$stmt -> execute();
*		$details= $stmt->fetchAll();
*		$stmt->closeCursor();
*	} catch (PDOException $e){
*		print "Error listing cars:" . $e->getMessage();
*		die();
*	}
*	$results['name'] = $details[0];
*	$results['year'] = $details[1];
*	$results['transmission'] = $details[2];
*	$results['avail'] = $details[3];
*
*
*    return $results;
*}
*/


/**
 * Retrieve information on cars located at a pod
 * @param string $pod name of pod
 * @return array Various details of each car - see homepod.php
 * @throws Exception 
 */
function getPodCars($pod) {

    // Return no cars if no pod specified
    if (empty($pod)) 
        return array();
    

    $db = connect();

    $availability = array();
    $carExists = array();
    $results = array();
        try {
           
        
            // get all AVAILABLE cars in a pod
            $stmt = $db -> prepare("SELECT DISTINCT(car) FROM carsharing.booking b 
            JOIN carsharing.car c ON c.regno = b.car 
            WHERE c.parkedat = (SELECT id FROM carsharing.pod WHERE name = :pod)
            AND (b.starttime > 'today' 
            OR b.endtime <= 'today')");
            $stmt -> bindValue(':pod', $pod, PDO::PARAM_STR);
            $stmt -> execute();   

            while ($column = $stmt -> fetchColumn()) {
                array_push($availability, $column);
            }

             
            $stmt -> closeCursor();
            $stmt = $db -> prepare('SELECT DISTINCT(car) FROM booking');
            // check for car records inside booking table
            $stmt -> execute();
            while ($row = $stmt -> fetchColumn()) {
                array_push($results, $row);
            }
            $stmt -> closeCursor();

             
            $stmt = $db -> prepare('SELECT regno, name, make, model, year, transmission FROM carsharing.car 
                WHERE parkedat = (SELECT id FROM carsharing.pod WHERE name = :pod)');
            // return selected car details
            $stmt -> bindValue(':pod', $pod, PDO::PARAM_STR);
            $stmt -> execute();

            while ($row = $stmt -> fetch()) {
                
                foreach($availability as $num) {
                    if ($num == $row['regno']) {
                        $row['avail'] = true;
                        break;
                    }
                    else {
                        $row['avail'] = false;
                    }
                }

                // check availability
                foreach($results as $exist) {
                    if ($row['regno']!=$exist) {
                        $row['avail'] = true;
                    } 
                }

                array_push($carExists, $row);
            }             
        }

        catch (PDOException $e) {
            print "Error retrieving details of pod cars!" .$e->getMessage();
        }        

        $stmt -> closeCursor();

       return $carExists;
}



/**
 * Retrieve information on active bookings for a user
 * @param string $user ID of member 
 * @return array Various details of each booking - see bookings.php
 * @throws Exception 
 */
// using stored procedure
function getOpenBookings($user) {
    $db = connect();
    try {
        $stmt = $db -> prepare('SELECT * FROM getBookings(:user) t(bookingid int, carname varchar(40), c carregtype, whenbooked timestamp, startdate date, starttime time, enddate date, endtime time)');	
        $stmt -> bindValue(':user',$user, PDO::PARAM_STR);
        $stmt -> execute();
        $results = $stmt -> fetchAll();
        $stmt -> closeCursor();
    }
    catch (PDOException $e) {
        print "Error accessing bookings : ". $e->getMessage();
        die();
    }
    return $results;
}

/**function getOpenBookings($user) {
    $db = connect();
    try {
        $stmt = $db -> prepare('SELECT Booking.id, Car.name, Car.regno, Booking.whenbooked, Booking.starttime::date, Booking.starttime::time, Booking.endtime::date, Booking.endtime::time
         FROM CarSharing.Booking 
         INNER JOIN CarSharing.Member on member.memberno=booking.madeby
         INNER JOIN CarSharing.Car on Car.regno=Booking.car
         WHERE member.nickname=username AND Booking.status='active' ORDER BY Booking.whenbooked DESC');  
        $stmt -> bindValue(':user',$user, PDO::PARAM_STR);
        $stmt -> execute();
        $results = $stmt -> fetchAll();
        $stmt -> closeCursor();
    }
    catch (PDOException $e) {
        print "Error accessing bookings : ". $e->getMessage();
        die();
    }
    return $results;
}
*/



function getReview($carname) {
    try{
        
        $dbh = connect();
 
        $stmt = $dbh->prepare('SELECT review.description, review.rating, review.nickname, review.whendone, c.name AS carname
                FROM carsharing.member, carsharing.car , carsharing.review
                WHERE car.name = :carname
                AND member.memberno = Review.memberno
                AND Car.regno = Rreview.regno
                ORDER BY R.whendone');
        $stmt->bindParam(':carname', $carname);
        
        $stmt->execute();
        
        $reviews = $stmt->fetchAll();
        
        $stmt->closeCursor();
    } catch (PDOException $e) {
        
        print "Error retrieving reviews!" . $e->getMessage();
        
        die();
        
        return FALSE;
    
    }
    return $reviews;
}




/**
 * Make a new booking for a car
 * @param string $user Member booking car
 * @param string $car Name of car to book
 * @param string $start
 * @return array Various details of current visit - see newbooking.php
 * @throws Exception 
 */
function makeBooking($user,$car,$tripdate,$starttime,$numhours) {
	$db = connect();
	$start = $tripdate . "\t" . $starttime;
	$db -> beginTransaction();
	try {
		
		$stmt = $db->prepare('SELECT id, car, start, en, status, pod, address, cost 
				FROM carsharing.MakeBooking(?, ?, ?, ?) 
				AS (id INTEGER, car VARCHAR, start TIMESTAMP, en TIMESTAMP, status VARCHAR, pod VARCHAR, address VARCHAR, cost INTEGER)');
		$stmt->bindParam(1, $user, PDO::PARAM_STR);
		$stmt->bindParam(2, $car, PDO::PARAM_STR);
		$stmt->bindParam(3, $start, PDO::PARAM_STR);
		$stmt->bindParam(4, $numhours, PDO::PARAM_INT);
		$stmt->execute();
		$data = $stmt->fetchAll();
		foreach($data as $row) {
			$results['id'] = $row['id'];
			$results['car'] = $row['car'];
			$results['start'] = $row['start'];
			$results['end'] = $row['en'];
			$results['status'] = $row['status'];
			$results['pod'] = $row['pod'];
			$results['address'] = $row['address'];
			$results['cost'] = $row['cost'];
		}
		$stmt->closeCursor();
				
	} catch (PDOException $e){
		print "Error creating booking! " . $e-> getMessage();
		$db->rollBack();
		return false;
	}
	$db->commit();
	return $results;
}

?>