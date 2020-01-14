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

}
if (!(is_empty($_POST['las_name'])))
{

}
if (!(is_empty($_POST['email'])))
{

}
if (!(is_empty($_POST['gender'])))
{

}

if (!(is_empty($_POST['orientation'])))
{

}
if (!(is_empty($_POST['biography'])))
{

}
if (!(is_empty($_POST['birth'])))
{

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
