<?php

// print_r($_POST);
// return;
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');


if (empty($_POST['email']))
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
else {
      try {
        User::send_account_retrieval($_POST['email'], $db, "http://localhost/retreive");

      echo  '{
        "result": "Success",
        "message": "Vous aller recevoir un mail de reinitilisation de mdp rapidement!",
        "alert": {
          "color": "DarkGreen",
          "message": "Vous aller recevoir un mail de reinitilisation de mdp rapidement!!"
        }
        }';
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
