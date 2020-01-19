<?php



session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

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

  echo '{
    "confirm" : true,
    "alert" : {
      "color" : "DarkGreen",
      "message" : "message sent"
    }
  }';
}

?>
