<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valEmail = $_GET['email'];
$valInviteretaf = $_GET['inviteretaf'];
$valRegnskabsnavn = $_GET['regnskabsnavn'];
$valRegnskabsid = $_GET['regnskabsid'];

$sql="INSERT INTO invitationToRegnskab (email,regnskabsid,inviteretAf,regnskabsnavn) VALUES($valEmail,$valRegnskabsid,$valInviteretaf,$valRegnskabsnavn)";
mysql_query($sql);



?>



