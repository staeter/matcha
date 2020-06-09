<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
$usr = unserialize($_SESSION['user']);

if (empty($_POST['oldpw']) || empty($_POST['newpw']) || empty($_POST['confirm']))
{
  echo 
  '{
    "result": "Failure",
    "message": "You must fill all fields !",
    "alert": 
    {
      "color": "DarkRed",
      "message": "You must fill all fields !"
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
  if ($usr->is_correct_password(hash_password($_POST['oldpw'])) == FALSE)
  {
    echo 
    '{
      "result": "Failure",
      "message": "Password doesnt match with the old one",
      "alert": 
      {
        "color": "DarkRed",
        "message": "Password doesnt match with the old one !"
      }
    }';
    return;
  }
  
  if (User::is_valid_password($_POST['newpw']) == FALSE)
  {
    echo 
    '{
      "result": "Failure",
      "message": "The new password is not valid",
      "alert": 
      {
      "color": "DarkRed",
      "message": "The new password is not valid!"
      }
    }';
    return;
  }

  $usr->set_password(hash_password($_POST['newpw']));
  echo 
  '{
    "result": "Success",
    "message": "Your password have been updated !",
    "alert": 
    {
      "color": "DarkGreen",
      "message": "Your Password Has beeen updated!"
    }
  }';
  } 
  catch (Exception $e) 
  {
    echo 
    '{
      "result": "Failure",
      "message": "'.$e->getMessage().'",
      "alert": 
      {
      "color": "DarkRed",
      "message": "A problem occur pls retry!"
      }
    }';
    return;
  }
}
