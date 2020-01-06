<?php
session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';

try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User($_POST['pseudo'], hash_password($_POST['password']), $db);
  if ($usr->is_validated_account())
  {

      $x = 1;
  }
  else
  {
			$x = 6;
	}
  if ($x = 1)
  {
    $_SESSION['id'] = $usr->get_id();
    $_SESSION['pseudo'] = $usr->get_pseudo();
    $_SESSION['mail'] = $usr->get_email();
    $usr->set_log(true);
  }

} catch (\Exception $e) {

  if ($e->getCode() == 30)
    $x = 2;
  else if ($e->getCode() == 31)
    $x = 3;
  else if ($e->getCode() == 32)
    $x = 4;
  else if ($e->getCode() == 33)
    $x = 5;
}

if ($x == 1){

      echo '{
        "result" : "Success",
        "message" : "Welcome !"
      }';
    }
else if ($x == 2){
  echo '{
    "result" : "Failure",
    "message" : "Mot de passe and/or password doesnt match !"
  }';

}
else if ($x == 3)
{
  echo '{
    "result" : "Failure",
    "message" : "Your pseudo doesnt exist!"
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
else if ($x == 6)
{
  echo '{
    "result" : "Failure",
    "message" : "Vous devez confirmer votre compte pour vous login"
  }';

}

else {
  echo '{
    "result" : "Failure",
    "message" : "probleme non determiné/gerer '.$e->getCode().'"
  }';
}


// pseudo password
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/

?>
