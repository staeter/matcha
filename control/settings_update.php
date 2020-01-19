<?php
// En gros ici si pseudo/firstname/etc existe et est différent de vide on lance la fonction qui teste tout ce qui existe
// comme ca l user peut envoyer plusieurs info en meme temps


//pseudo first_name last_name email gender orientation biography birth pictures tags

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';


$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);

if (!(is_empty($_POST['pseudo'])))
{
  if ($usr->is_valid_pseudo($_POST['pseudo'] == TRUE))
  {
        $usr->set_pseudo($_POST['pseudo']);
  }
  else {
    echo '{
      "result" : "Failure",
      "message" : "'.$e->getMessage().'"
    }';
  }
}

if (!(is_empty($_POST['first_name'])))
{
  $usr->set_first_name($_POST['first_name']);
}
if (!(is_empty($_POST['last_name'])))
{
    $usr->set_last_name($_POST['last_name']);
}
if (!(is_empty($_POST['email'])))
{
  if ($usr->is_valid_email($_POST['email']) == FALSE)
  {
    echo '{
      "result" : "Failure",
      "message" : "Le mail n est pas valide"
    }';
    return;
  }

  if ($usr->is_email_in_use($_POST['email']) == false)
    $usr->set_email($_POST['email']);
  else {
    echo '{
      "result" : "Failure",
      "message" : "Le mail choisi est déjà utiliser"
    }';
  }
}
if (!(is_empty($_POST['gender'])))
{
  $usr->set_gender($_POST['gender']);
}

if (!(is_empty($_POST['orientation'])))
{
  $usr->set_sexuality_orientation($_POST['orientation']);
}

if (!(is_empty($_POST['biography'])))
{
  $usr->set_biography($_POST['biography']);

}

if (!(is_empty($_POST['birth'])))
{
  $usr->set_birthdate($POST['birth']);
}

//if (!(is_empty($_POST['pictures'])))
//{

// }
// if (!(is_empty($_POST['tags'])))
// {
//
// }

/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
