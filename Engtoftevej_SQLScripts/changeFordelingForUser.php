<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valPersonIdent = $_GET['personIdent'];
$valFordeling = $_GET['fordeling'];
$valRegnskabsIdent = $_GET['regnskabsIdent'];

mysql_query("UPDATE accountingAndPeople SET fordelingprocent=$valFordeling WHERE person=$valPersonIdent && regnskabsId=$valRegnskabsIdent") 
or die(mysql_error());  

?>



