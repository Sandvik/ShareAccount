<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valModel = $_GET['afregnIndividuel'];
$valRegnskabsid = $_GET['regnskabsid'];

$sql2="UPDATE engtoftevej_accounting SET afregnIndividuel=$valModel where id = $valRegnskabsid";
mysql_query($sql2);


?>



