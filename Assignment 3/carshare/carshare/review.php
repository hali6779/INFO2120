<?php 
/**
 * Reviews and Ratings Page
 * 
 */
require_once('include/common.php');
require_once('include/database.php');
startValidSession();
htmlHead();
?>

<h1>Reviews and Ratings</h1>




<?php 
try {
    $reviews = getReview($_GET['carname']);
?>
</form>
<table>
<thead>
<tr><th>Comments</th><th>Rating</th><th>Username</th><th>Date Written</th></tr>
</thead>
<tbody>
<?php
foreach($reviews as $review) {
    echo '<tr><td>',$review['description'],'</td><td>',$review['rating'],'</td>',
            '<td>',$review['nickname'],'</td><td>',$review['whendone'],'</td></tr>';
}
?>
</tbody>
</table>
<?php
} catch (Exception $e) {
        echo 'Could not write your review';
}
htmlFoot();
?>