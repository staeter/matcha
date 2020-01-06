<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

// if (empty($_POST['password']) || empty($_POST['confirm']))
// {
//     echo '{
//       "result" : "Failure",
//       "message" : "Vous devez remplir tout les champs."
//     }';
// }

if (strcmp($_POST['oldpw'], $_POST['newpw']) !== 0)
{
  echo '{
    "result" : "Failure",
    "message" : "Passwords doesnt match."
  }';
}
else {

  try {
    $id = 41;
    $pw = 'so';
    $newpw = 'sosa';

    $usr = new User('iphone', hash_password($pw), $db);
    $usr->set_password(hash_password($newpw));

    echo '{
      "result" : "Success",
      "message" : "You are connected ! (object created)."
    }';

  } catch (\Exception $e) {
    echo '{
      "result" : "Failure",
      "message" : "'.$e->getMessage().'"
    }';

  }

}

//oldpw newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/

?>
