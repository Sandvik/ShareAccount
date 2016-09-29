<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valPast = $_GET['past'];
$valRegnskabsid = $_GET['regnskabsid'];

if ($valPast) {
	$result = mysql_query("SELECT * FROM chatitems WHERE regnskabsID =$valRegnskabsid && id > $valPast ORDER BY added LIMIT 50");
} else {
	$result = mysql_query("SELECT * FROM chatitems WHERE regnskabsID =$valRegnskabsid ORDER BY added LIMIT 50");	
}

$rows = array();
while($r = mysql_fetch_assoc($result)) {
    $rows[] = $r;
}
print json_encode($rows);
//mysql_close($link);
?>
