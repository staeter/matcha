<?php

session_start();
require '../model/classes/User.class.php';

$check = -1;

try 
{
  $usr = unserialize($_SESSION['user']);
  $usr->set_log(0);

  $_SESSION['id'] = NULL;
  $_SESSION['pseudo'] = NULL;
  $_SESSION['mail'] = NULL;
  $_SESSION['user'] = NULL;
  $_SESSION['picture'] = NULL;
  $check = 1;
  session_destroy();
} 
catch (Exception $e) 
{
  $check = 0;
}

if ($check == 1)
{
  echo 
  '{
    "result" : "Success",
    "message" : "You been disconnect with success !"
  }';
}
else 
{
  echo 
  '{
    "result" : "Failure",
    "message" : "A problem occur when we trying to disconnect you !"
  }';
}