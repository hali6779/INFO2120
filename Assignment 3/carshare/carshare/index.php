<?php 
/**
 * Home page giving details of a specific user
 */
require_once('include/common.php');
require_once('include/database.php');
startValidSession();
htmlHead();
?>
<h1>Home</h1>
<?php 
try {
    $details = getUserDetails($_SESSION['member']);
    echo '<h2>Name</h2> ',$details['givenname'], ' ', $details['familyname'];
    echo '<h2>Address</h2>',$details['address'];
    
    if(is_null($details['podname']))
    {
    	echo '<h2> Home Pod </h2> Home pod has not beet set!';
    } else {
    	echo '<h2>Home Pod</h2>',$details['podname'];
    }
    echo '<h2>Total bookings</h2> ',$details['nbookings'];
} catch (Exception $e) {
    echo 'Cannot get user details';
}
htmlFoot();
?>