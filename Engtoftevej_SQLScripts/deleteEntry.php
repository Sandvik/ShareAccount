<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valIdent = $_GET['ident'];

mysql_query("DELETE FROM engtoftevej WHERE id=$valIdent") 
or die(mysql_error()); 
?>



