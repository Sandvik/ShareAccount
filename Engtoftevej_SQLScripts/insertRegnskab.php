<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valFraDato = $_GET['fradato'];
$valTilDato = $_GET['tildato'];
$valRegnskab = $_GET['regnskab'];
$valRegnskabsid = $_GET['regnskabsid'];
$valStatus = $_GET['status'];

$sql="INSERT INTO engtoftevej_accounting (fraDato,tildato,regnskab,regnskabsid,status) VALUES($valFraDato,$valTilDato,$valRegnskab,$valRegnskabsid,$valStatus)";
mysql_query($sql);

$sql2="UPDATE engtoftevej SET afstemtYN='JA' where regnskabsID = $valRegnskabsid";
mysql_query($sql2);


?>



