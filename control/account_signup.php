<?php
session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';
require_once $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
$db = new Database($dsn . ";dbname=" . $dbname, $username, $password);
//$x is the check value
$x = 0;

if (empty($_POST['password']) || empty($_POST['confirm']) || empty($_POST['firstname']) || empty($_POST['lastname']) || empty($_POST['email']) || empty($_POST['pseudo']))
{
  echo 
  '{
    "result" : "Failure",
    "message" : "Vous devez remplir tout les champs."
  }';
}
else if (strcmp($_POST['password'], $_POST['confirm']) !== 0)
{
  echo 
  '{
    "result" : "Failure",
    "message" : "Passwords doesnt match."
  }';
}
else if (User::is_valid_password($_POST['confirm']) == false)
{
  echo 
  '{
    "result" : "Failure",
    "message" : "Passwords insecure."
  }';
}
else 
{
  try 
  {
    $usr = new User($_POST['pseudo'], $_POST['firstname'], $_POST['lastname'], $_POST['email'], hash_password($_POST['password']), $db);
    $usr->send_account_verification_request("http://localhost:8080/confirm");
    $usr->set_picture();
    $x = 1;
  }
  catch (Exception $e) 
  {
  if ($e->getCode() == 42)
    $x = 2;
  else if ($e->getCode() == 41)
    $x = 3;
  else if ($e->getCode() == 43)
    $x = 4;
  else if ($e->getCode() == 44)
    $x = 5;
  else
    $x = -1;
  }

  if ($x == 1)
  {
    echo 
    '{
      "result" : "Success",
      "message" : "We just sent you an email. You have to confirm it before signing in."
    }';
  }
  else if ($x == 2)
  {
    echo '{
      "result" : "Failure",
      "message" : Invalid Mail or is already taken"
    }';
  }
  else if ($x == 3)
  {
    echo 
    '{
      "result" : "Failure",
      "message" : "Your pseudo is invalid ! -> .'.$e->getMessage().'"
    }';
  }
  else if ($x == 4)
  {
    echo 
    '{
      "result" : "Failure",
      "message" : "Your password is invalid ! -> .'.$e->getMessage().'"
    }';
  }
  else if ($x == 5)
  {
    echo 
    '{
      "result" : "Failure",
      "message" : "The connection with Database Failed ! -> .'.$e->getMessage().'"
    }';
  }
  else 
  {
    echo 
    '{
      "result" : "Failure",
      "message" : "Undefined problem -> '.$e->getMessage().'"
    }';
  }
}
