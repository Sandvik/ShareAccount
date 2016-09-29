<?php
$con = mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valNavn = $_GET['navn'];
$valPerson = $_GET['personid'];
$valEmail = $_GET['email'];
$valUser = $_GET['usernavn'];

$sql = "INSERT INTO engtoftevej_accounting (navn,oprettetAfPersonID) VALUES($valNavn,$valPerson)";
mysql_query($sql);

//mysql_query($add_to_client_query);
$last = Mysql_insert_id();
$add_to_booking_query = "insert into accountingAndPeople (person, regnskabsId,email, usernavn,fordelingprocent) values ($valPerson,$last,$valEmail,$valUser,100)";
mysql_query($add_to_booking_query);

print $last;
?>



