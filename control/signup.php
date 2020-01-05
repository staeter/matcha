<?php


session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';
$x =0;


$pseudo = $_POST['pseudo'];
$psw = $_POST['password'];
$pswconfirm = $_POST['confirm'];
$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

// if ($psw != $pswconfirm)
// {
//   echo '{
//     "result" : "Failure",
//     "message" : "The password and confirm must be the same !"
//   }';
// }
//
// else if (strlen($pseudo) < 3 || strlen($_POST['firstname']) < 3 || strlen($_POST['lastname']) < 3)
//   {
//     echo '{
//       "result" : "Failure",
//       "message" : "The pseudo / firstname / lastname must be more than 3 char!"
//     }';
//   }
//
// else {
try {

  $usr = new User($_POST['pseudo'], $_POST['firstname'], $_POST['lastname'], $_POST['email'], hash_password($_POST['password']), $db);
  $x = 1;

} catch (Exception $e) {

  if ($e->getCode() == 42)
    $x = 2;
  else if ($e->getCode() == 41)
    $x = 3;
  else if ($e->getCode() == 43)
    $x = 4;
  else if ($e->getCode() == 44)
    $x = 5;


}


//
// $pseudo = $_POST['pseudo'];
//
// $c = strlen($pseudo);
//
// //if (isset($_POST['pseudo']))
//   if ($c > 1)
//   $x = 1;


// if ((isset($_POST['pseudo'])) && (isset($_POST['firstname'])) && (isset($_POST['lastname']))
//       && (isset($_POST['email'])) && (isset($_POST['password'])) && (isset($_POST['confirm'])))
//     {

if ($x == 1){
      echo '{
        "result" : "Success",
        "message" : "We just sent you an email. You have to confirm it before signing in."
      }';
    }
else if ($x == 2){
  echo '{
    "result" : "Failure",
    "message" : "Probleme de mail soit non valide soit deja pris check -->.'.$e->getMessage().'"
  }';

}
else if ($x == 3)
{
  echo '{
    "result" : "Failure",
    "message" : "Votre pseudo est invalide ! .'.$e->getMessage().'"
  }';

}
else if ($x == 4)
{
  echo '{
    "result" : "Failure",
    "message" : "Votre password est invalide ! .'.$e->getMessage().'"
  }';

}
else if ($x == 5)
{
  echo '{
    "result" : "Failure",
    "message" : "La connexion a la db a échoué ! .'.$e->getMessage().'"
  }';

}

else {
  echo '{
    "result" : "Failure",
    "message" : "c mort de chez mort '.$e->getCode().'"
  }';
}

// pseudo lastname firstname email password confirm
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/

?>
