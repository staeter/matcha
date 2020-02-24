<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
require_once $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
  $db = new Database($dsn . ";dbname=" . $dbname, $username, $password);
// print_r($_POST);
// return;

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
        $usr = new User($_POST['a'], $db);
        $usr->set_password(hash_password($_POST['confirm']));
        //User::send_account_retrieval($_POST['b'], $db, "http://localhost/control/account_retreivial.php");
      //  User::

      echo '{
      "result": "Success",
      "message": "Ur password have been updated!",
      "alert": {
        "color": "DarkGreen",
        "message": "Ur password have been updated!!"
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
