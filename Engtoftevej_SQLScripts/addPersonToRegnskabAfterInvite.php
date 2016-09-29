<?php
$con = mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valPerson = $_GET['personId'];
$valRegnskab = $_GET['regnskabsId'];
$valEmail = $_GET['email'];
$valUser = $_GET['user'];

$add_to_booking_query = "insert into accountingAndPeople (person, regnskabsId,email,usernavn,fordelingprocent) values ($valPerson,$valRegnskab,$valEmail,$valUser,100)";
mysql_query($add_to_booking_query);

$add_to_delete_query="delete FROM invitationToRegnskab WHERE email =$valEmail && regnskabsId= $valRegnskab";
mysql_query($add_to_delete_query);
?>



