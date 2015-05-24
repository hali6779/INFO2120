<?php 
/**
 * Web page to create a new booking
 */
require_once('include/common.php');
require_once('include/database.php');
startValidSession();
htmlHead();
?>
<h1>Make new booking</h1>
<?php
// Check whether all attributes for booking have been submitted
$submit = !empty($_REQUEST['car']) 
	&& !empty($_REQUEST['tripdate']) 
	&& !empty($_REQUEST['starttime']) 
	&& !empty($_REQUEST['numhours']);
$booking = null;
	
if ($submit) {
echo 'Submitting booking.';
    try {
        $booking = makeBooking($_SESSION['member'], $_REQUEST['car'], $_REQUEST['tripdate'], $_REQUEST['starttime'], $_REQUEST['numhours']);
        if($booking['status'] == 'active') { 
            echo '<h2>Congratulations, you\'ve made a new new booking!';
			echo '<h2>Booking ID</h2> ',$booking['id'];
			echo '<h2>Car</h2> ',$booking['car'];
			echo '<h2>Starting</h2> ',$booking['start'];
			echo '<h2>Ending</h2> ',$booking['end'];
			echo '<h2>Pod</h2> ',$booking['pod'];
			echo '<h2>Address</h2> ',$booking['address'];
			echo '<h2>Estimated cost</h2> $',$booking['cost'] / 100 ;
        } else {
            echo '<h2>Sorry, couldn\'t make a booking:</h2>', $booking['status'];
        }
    } catch (Exception $e) {
            echo 'Couldn\'t submit booking. Please try again.';
    }
} else {
	echo 'Please complete all the booking details.';
}

if (!$submit || $booking==null || $booking['status'] != 'active') {
	// Supply defaults for any unset values	
	$carname = isset($_REQUEST['car']) ? $_REQUEST['car'] : '';
	$tripdate = isset($_REQUEST['tripdate']) ? $_REQUEST['tripdate'] : date("Y-m-d");
	$starttime = isset($_REQUEST['starttime']) ? $_REQUEST['starttime'] : date("H:00:00");
	$numhours = isset($_REQUEST['numhours']) ? $_REQUEST['numhours'] : 1;	

?>
    <form action="newbooking.php" id="newbooking" method="post">
        <label>Car <input type="text" name="car" value="<?php echo $carname;?>"/></label><br />
		<label>Trip date <input type="date" name="tripdate"  value="<?php echo $tripdate;?>"/></label><br />
		<label>Start time <input type="time" step="3600" name="starttime" min="00:00:00" value="<?php echo $starttime;?>"/></label><br />
		<label>Duration (hours) <input type="number" step="1" name="numhours" min="1" value="<?php echo $numhours;?>"/></label><br />
		<br /><input type=submit value="Request Booking"/>
    </form>
<?php
}
htmlFoot();
?>
