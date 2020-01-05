<?php


session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';
$x =0;


$pseudo = $_POST['pseudo'];
$psw = $_POST['password'];
$pswconfirm = $_POST['confirm'];
$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

if ($psw != $pswconfirm)
{
  echo '{
    "result" : "Failure",
    "message" : "The password and confirm must be the same !"
  }';
}

else if (strlen($pseudo) < 3 || strlen($_POST['firstname']) < 3 || strlen($_POST['lastname']) < 3)
  {
    echo '{
      "result" : "Failure",
      "message" : "The pseudo / firstname / lastname must be more than 3 char!"
    }';
  }

else {
try {

  $usr = new User($_POST['pseudo'], $_POST['firstname'], $_POST['lastname'], $_POST['email'], hash_password($_POST['password']), $db);
  $x = 1;

} catch (Exception $e) {

  if ($e->getCode() == 42)
  {
    echo '{
      "result" : "Failure",
      "message" :  '.$e->getMessage().'
    }';


  }


}



$pseudo = $_POST['pseudo'];

$c = strlen($pseudo);

//if (isset($_POST['pseudo']))
  if ($c > 1)
  $x = 1;


// if ((isset($_POST['pseudo'])) && (isset($_POST['firstname'])) && (isset($_POST['lastname']))
//       && (isset($_POST['email'])) && (isset($_POST['password'])) && (isset($_POST['confirm'])))
//     {

if ($x == 1){
      echo '{
        "result" : "Success",
        "message" : "We just sent you an email. You have to confirm it before signing in."
      }';
    }
else{
  echo '{
    "result" : "Failure",
    "message" : "You need to fill all the champs for complete the sign up."
  }';

}
}
// pseudo lastname firstname email password confirm
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/

?>
