<?php
// En gros ici si pseudo/firstname/etc existe et est différent de vide on lance la fonction qui teste tout ce qui existe
// comme ca l user peut envoyer plusieurs info en meme temps


//pseudo first_name last_name email gender orientation biography birth pictures tags

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';


$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

if (!(is_empty($_POST['pseudo'])))
{
  if (User::is_valid_password($_POST['pseudo'] == TRUE))
  {
        User::set_password(hash_password($_POST['pseudo']));
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
  User::set_first_name($_POST['first_name']);
}
if (!(is_empty($_POST['last_name'])))
{
    User::set_last_name($_POST['last_name']);
}
if (!(is_empty($_POST['email'])))
{
  User::set_email($_POST['email']);
}
if (!(is_empty($_POST['gender'])))
{
  User::set_gender($_POST['gender']);
}

if (!(is_empty($_POST['orientation'])))
{
  User::set_sexuality_orientation($_POST['orientation']);

}
if (!(is_empty($_POST['biography'])))
{
  User::set_biography($_POST['biography']);

}
if (!(is_empty($_POST['birth'])))
{
  User::set_birthdate($POST['birth']);
}

if (!(is_empty($_POST['pictures'])))
{

}
if (!(is_empty($_POST['tags'])))
{

}

/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
