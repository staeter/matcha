<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');


if (empty($_POST['b']) || empty($_POST['newpw']) || empty($_POST['confirm']) || empty($_POST['a']))
{
  echo
  '{
  "result": "Failure",
  "message": "Vous devez remplir tous les champs!",
  "alert": {
    "color": "DarkRed",
    "message": "Vous devez remplir tous les champs!"
}
}';
return;
}
else if (strcmp($_POST['confirm'], $_POST['newpw']) !== 0)
{
  echo '{
  "result": "Failure",
  "message": "New Password and Confirm doesnt match!",
  "alert": {
    "color": "DarkRed",
    "message": "New Password and Confirm doesnt match!"
}
}';
return;
}
else {
      try {
        //User::send_account_retrieval($_POST['b'], $db, "http://localhost/control/account_retreivial.php");
      //  User::
         }
        catch (Exception $e) {
          echo '{
            "result" : "Failure",
            "message" : "'.$e->getMessage().'"
          }';
        return;
	}
// a b newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
}
?>
