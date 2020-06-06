<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

if ($usr->is_id_exist($_POST['id']) == false)
{
  echo 
  '{
    "confirm" : false,
    "alert" : 
    {
      "color" : "DarkRed",
      "message" : "Message Not sent the user requested because he doesnt exist"
    }
  }';
  return;
}
else if(empty($_POST['content']))
{
  echo 
  '{
    "confirm" : false,
    "alert" : 
    {
      "color" : "DarkRed",
      "message" : "You cant send an empty message"
    }
  }';
  return;
}
else 
{
  $usr->send_message_to_id($_POST['id'], strip_tags($_POST['content']));
  $usr->set_a_notif_for_new_message($_POST['id']);

  echo 
  '{
    "confirm" : true,
    "alert" : 
    {
      "color" : "DarkGreen",
      "message" : "message sent"
    }
  }';
  return;
}