<?php 
/**
 * Web page to get details of a pod, defaulting to a user's home pod
 */
require_once('include/common.php');
require_once('include/database.php');
startValidSession();
htmlHead();
?>
<h1>Pod Details</h1>
<?php 
try {
	$podId = isset($_REQUEST['pod']) ? $_REQUEST['pod'] : $podId = getHomePod($_SESSION['member']);
	$cars = getPodCars($podId);
	
?>
	


	<form action="homepod.php" id="podname" method="post">
	<label>Pod Name <input type=text name="pod" value="<?php echo $podId?>"/></label>
	<input type=submit value="Update"/>
	</form>
<?php
    if(count($cars)>0) {
		echo '<table>';
		echo '<thead>';
		echo '<tr>
		<th>Registration #</th>
		<th>Nickname</th>
		<th>Make</th>
		<th>Model</th>
		<th>Year</th>
		<th>Transmission</th>
		<th>Available</th>

		</tr>';
		echo '</thead>';
		echo '<tbody>';
		foreach($cars as $car) {
			echo '<tr><td><a href="newbooking.php?car=',$car['name'],'">',$car['regno'],'</td>
			<td>',$car['name'],'</td>
			<td>',$car['make'],'</td>
			<td>',$car['model'],'</td>
			<td>',$car['year'],'</td>
			<td>',$car['transmission'],'</td>
			<td>',$car['avail']==true ? 'Available' : 'Unavailable', '</td></tr>';
		}
		echo '</tbody>';
		echo '</table>';
    } else {
		echo '<p>No cars found or invalid pod. Try another pod.</p>';
	}
} catch (Exception $e) {
    echo 'Cannot get current pod status';
}
htmlFoot();
?>
