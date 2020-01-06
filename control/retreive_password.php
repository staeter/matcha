<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

try {
    User::send_account_retrieval($_POST['email'], $db, "http://localhost:8080/control/account_retreivial.php");
	  }
  catch (Exception $e) {
    echo '{
      "result" : "Failure",
      "message" : "'.$e->getMessage().'"
    }';
	}
// a b newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
?>
