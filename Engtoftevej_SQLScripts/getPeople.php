<?php
//$val = $_GET['word']; 
//echo "the word is: $val <p><br>"; 
?>

<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valEmail = $_GET['email'];

$sql=mysql_query("SELECT * FROM `engtoftevej_people` WHERE emailadresse = $valEmail");
$rows = array();
while($r = mysql_fetch_assoc($sql)) {
    $rows[] = $r;
}
print json_encode($rows);
//mysql_close($link);
?>



