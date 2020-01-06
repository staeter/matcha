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

// if (strcmp($_POST['oldpw'], $_POST['newpw']) !== 0)
// {
//   echo '{
//     "result" : "Failure",
//     "message" : "Passwords doesnt match."
//   }';
// }
// else {

  try {
    $id = 41;
    $pw = 's';
    $newpw = 'skssk12&skskksksoa';
//User::send_account_retrieval
  //  $usr = new User('iphone', hash_password($pw), $db);
      if (User::is_valid_password($newpw) == true)
      {
        echo 'salut';
      }

    // echo '{
    //   "result" : "Success",
    //   "message" : "is valid hashed psw ! (object created)."
    // }';

  } catch (\Exception $e) {
    echo '{
      "result" : "Failure",
      "message" : "rooo'.$e->getMessage().'"
    }';

  }
//
// }

//oldpw newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/

?>
