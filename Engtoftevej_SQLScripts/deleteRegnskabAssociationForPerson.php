<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valregnskabsid = $_GET['regnskabident'];
$valPersonid = $_GET['personident'];

mysql_query("DELETE FROM engtoftevej WHERE regnskabsID=$valregnskabsid && personID=$valPersonid") 
or die(mysql_error()); 

mysql_query("DELETE FROM accountingAndPeople WHERE regnskabsid=$valregnskabsid && person=$valPersonid") 
or die(mysql_error()); 

?>



