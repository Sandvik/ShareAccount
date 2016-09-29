<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valPrice = $_GET['pris'];
$valType = $_GET['type'];
$valPerson = $_GET['person'];
$valRegnskabsid = $_GET['regnskabsid'];
$valPersonid = $_GET['personid'];
$valPostnote = $_GET['postnote'];

$sql="INSERT INTO engtoftevej(type,price,person,afstemtYN,regnskabsID,personID,postnote) VALUES($valType,$valPrice,$valPerson,'NEJ',$valRegnskabsid,$valPersonid,$valPostnote)";
mysql_query($sql);

$last = Mysql_insert_id();
print $last;
?>



