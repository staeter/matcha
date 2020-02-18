<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

if (empty($_POST['oldpw']) || empty($_POST['newpw']) || empty($_POST['confirm']))
{
  echo '{
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
    $usr = new User($_SESSION['id'], $db);

    if ($usr->is_correct_password(hash_password($_POST['oldpw'])) == FALSE)
{
  echo '{
  "result": "Failure",
  "message": "Le mot de passe ne correspond pas à a celui enregistré",
  "alert": {
    "color": "DarkRed",
    "message": "OLD OLD Password doesnt match!"
}
}';
     return;
   }

  if (User::is_valid_password($_POST['newpw']) == FALSE)
      {
        echo '{
        "result": "Failure",
        "message": "The new password is not valid",
        "alert": {
          "color": "DarkRed",
          "message": "OLD OLD Password doesnt match!"
      }
      }';
      return;
    }

    $usr->set_password(hash_password($_POST['newpw']));


    echo '{
    "result": "Success",
    "message": "Votre password à bien été mis à jour !",
    "alert": {
      "color": "DarkGreen",
      "message": "Your Password Has beeen updated!"
    }
    }';

    /**/
    //      Le code fonctionne en mode test (variable determiner au lieu de session & post)
    //      Check le retour du echo dans le try (ca marche pas)
    //
    /**/

    // echo '{
    //   "result" : "Success",
    //   "message" : "Your password have been updated."
    // }';

  } catch (Exception $e) {
    echo '{
    "result": "Failure",
    "message": "'.$e->getMessage().'",
    "alert": {
      "color": "DarkRed",
      "message": "A problem occur pls retry!"
  }
  }';
  return;
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
