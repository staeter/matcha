<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

if ($usr->is_id_exist($_POST['id']) == false)
{
  echo '{
    "confirm" : false,
    "alert" : {
      "color" : "DarkRed",
      "message" : "message Not sent the id requested doesnt exist"
    }
  }';
  return;
}

else if(empty($_POST['content']))
{
  echo '{
    "confirm" : false,
    "alert" : {
      "color" : "DarkRed",
      "message" : "You cant send a message without character"
    }
  }';
  return;
}

else {

  $usr->send_message_to_id($_POST['id'], $_POST['content']);
  $usr->set_a_notif_for_new_message($_POST['id']);

  echo '{
    "confirm" : true,
    "alert" : {
      "color" : "DarkGreen",
      "message" : "message sent"
    }
  }';
}

?>
