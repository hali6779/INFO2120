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
?>

<table>;
<thead>
<tr><th>Car Name</th><th>Date</th><th>Start Time</th><th>End Time</th></tr>
</thead>
<tbody>
<?php
    foreach($bookings as $booking) {
        echo '<tr><td>',$booking['name'],'</td><td>',$booking['date'],'</td>',
            '<td>',$booking['start'],'</td><td>',$booking['end'],'</td>',
            '</tr>';


}
?>
</tbody>
</table>
<?php
} catch (Exception $e) {
        echo 'Cannot get available bookings';
}
htmlFoot();
?>