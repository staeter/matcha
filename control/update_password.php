<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

if (empty($_POST['oldpw']) || empty($_POST['newpw']))
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

  try {

    $usr = new User($_SESSION['pseudo'], hash_password($POST['oldpw']), $db);
    $usr->set_password(hash_password($_POST['newpw']));

    /**/
    //      Le code fonctionne en mode test (variable determiner au lieu de session & post)
    //      Check le retour du echo dans le try (ca marche pas)
    //
    /**/

    echo '{
      "result" : "Success",
      "message" : "Your password have been updated."
    }';

  } catch (Exception $e) {
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
