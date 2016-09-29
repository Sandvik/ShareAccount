<?php
header( 'Content-type: text/xml' );

mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');	

$valmessage = $_GET['message'];
$valPerson = $_GET['user'];
$valRegnskabsid = $_GET['regnskabsid'];


$sql="INSERT INTO chatitems(user,message,regnskabsID) VALUES($valPerson,$valmessage,$valRegnskabsid)";
mysql_query($sql);	
	
?>




<success />
