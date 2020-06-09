<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
require_once $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';

$db = new Database($dsn . ";dbname=" . $dbname, $username, $password);

if (empty($_POST['b']) || empty($_POST['newpw']) || empty($_POST['confirm']) || empty($_POST['a']))
{
  echo
  '{
    "result": "Failure",
    "message": "Vous devez remplir tous les champs!",
    "alert": 
    {
      "color": "DarkRed",
      "message": "Vous devez remplir tous les champs!"
    }
  }';
  return;
}
else if (strcmp($_POST['confirm'], $_POST['newpw']) !== 0)
{
  echo 
  '{
    "result": "Failure",
    "message": "New Password and Confirm doesnt match!",
    "alert": 
    {
    "color": "DarkRed",
    "message": "New Password and Confirm doesnt match!"
    }
  }';
  return;
}
else 
{
  try
  {  
    $usr = new User($_POST['a'], $db);
    $x =  $usr->is_valid_password($_POST['newpw']);
    if ($x == TRUE)
    {
      $usr->set_password(hash_password($_POST['newpw']));

      echo 
      '{
        "result": "Success",
        "message": "Votre password a bien ete modifie!",
        "alert": 
        {
          "color": "DarkGreen",
          "message": "Votre password a bien ete modifie!"
        }
      }';
 		}
    else 
    {
      echo 
      '{
        "result": "Failure",
        "message": "New Password insecure!",
        "alert": 
        {
          "color": "DarkRed",
          "message": "New Password insecure!"
        }
      }';
    }
  }
  catch (Exception $e) 
  {
    echo 
    '{
      "result" : "Failure",
      "message" : "'.$e->getMessage().'"
    }';
    return;
	}
}
