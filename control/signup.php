<?php
session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';

$x = 0;

if (empty($_POST['password']) || empty($_POST['confirm']) || empty($_POST['firstname']) || empty($_POST['lastname']) || empty($_POST['email']) || empty($_POST['pseudo']))
{
  echo '{
    "result" : "Failure",
    "message" : "Vous devez remplir tout les champs."
  }';
}
else {

  try {
    $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
    $usr = new User($_POST['pseudo'], $_POST['firstname'], $_POST['lastname'], $_POST['email'], hash_password($_POST['password']), $db);
    $x = 1;
      }
  catch (Exception $e) {

  if ($e->getCode() == 42)
    $x = 2;
  else if ($e->getCode() == 41)
    $x = 3;
  else if ($e->getCode() == 43)
    $x = 4;
  else if ($e->getCode() == 44)
    $x = 5;             }
/*
//
//          Apres le try, selon le message d'erreur ou de réussite on renvoi le bon message JSON
//
//          Probleme de code, ne gere pas la validations du password, (diffuclté & si le meme que confirm)
//           tout le monde peut avoir le meme pseudo
*/

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
    "message" : "probleme non determiné/gerer '.$e->getCode().'"
  }';
}
}


?>
