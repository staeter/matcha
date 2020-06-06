<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

$usr->set_a_report($_POST['id']);
$usr->substract_popularity_of_this_user($_POST['id']);

echo 
'{
  "result" : "Success",
  "message" : "user reported!"
}';