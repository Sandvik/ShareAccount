<?php
$con = mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valRegnskab = $_GET['regnskabsId'];
$valEmail = $_GET['email'];

$add_to_delete_query="delete FROM invitationToRegnskab WHERE email =$valEmail && regnskabsId= $valRegnskab";
mysql_query($add_to_delete_query);
?>



