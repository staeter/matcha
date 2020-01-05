<?php
session_start();

require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';
$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

if (empty($_POST['password']) || empty($_POST['confirm']))
{
    echo '{
      "result" : "Failure",
      "message" : "Vous devez remplir tout les champs."
    }';
}

else if (strcmp($_POST['oldpw'], $_POST['newpw']) !== 0)
{
  echo '{
    "result" : "Failure",
    "message" : "Passwords doesnt match."
  }';
}
else {

  
}

//oldpw newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
?>
