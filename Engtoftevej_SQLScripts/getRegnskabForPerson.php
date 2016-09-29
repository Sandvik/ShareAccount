<?php
//$val = $_GET['word']; 
//echo "the word is: $val <p><br>"; 
?>

<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valEmail = $_GET['email'];

$sql=mysql_query("SELECT * FROM engtoftevej_accounting WHERE id in(SELECT regnskabsid FROM accountingAndPeople WHERE person in(SELECT id FROM  engtoftevej_people where emailadresse = $valEmail))");
$rows = array();
while($r = mysql_fetch_assoc($sql)) {
    $rows[] = $r;
}
print json_encode($rows);
//mysql_close($link);
?>



