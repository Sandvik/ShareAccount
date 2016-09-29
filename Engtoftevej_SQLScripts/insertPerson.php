<?php
mysql_connect('mysql09.cliche.dk','sandviks.dk','gf98mmvs');
mysql_select_db('sandviks_dk');

$valPerson = $_GET['person'];
$valEmail = $_GET['email'];
$valPassword = $_GET['password'];
$valFuldtNavn = $_GET['fuldtnavn'];

echo "the word is: $valPerson"; 

$sql="INSERT INTO engtoftevej_people (person,emailadresse,password,fuldtnavn) VALUES($valPerson,$valEmail,$valPassword,$valFuldtNavn)";
mysql_query($sql);




?>



