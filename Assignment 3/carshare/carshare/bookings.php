<?php 
/**
 * Web page to display users active bookings
 */
require_once('include/common.php');
require_once('include/database.php');
startValidSession();
htmlHead();
?>
<h1>Active Bookings</h1>
<?php 
try {
    $bookings = getOpenBookings($_SESSION['member']);
    echo '<table>';
    echo '<thead>';
    echo '<tr><th>Booking ID</th><th>Car</th><th>Date</th><th>Start Time</th><th>End Date</th><th>End Time</th></tr>';
    echo '</thead>';
    echo '<tbody>';
    foreach($bookings as $booking) {
        echo '<tr><td>',$booking['bookingid'],'</td>',
                '<td>',$booking['carname'],'</td>',
                '<td>',$booking['startdate'],'</td>',
                '<td>',$booking['starttime'],'</td>',
                '<td>',$booking['enddate'],'</td>',
                '<td>',$booking['endtime'],'</td></tr>';
    }
    echo '</tbody>';
    echo '</table>';
} catch (Exception $e) {
        echo 'Cannot get available bookings';
}
htmlFoot();
?>
