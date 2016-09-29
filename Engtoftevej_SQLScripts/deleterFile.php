<?php
$uploadedFile = $_GET['file2Delete'];

//$uploadedFile = "uploads/438.png";
unlink($uploadedFile);
?>