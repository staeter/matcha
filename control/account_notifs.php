<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

// fonction qui recupere toutes les notifs de tel ID_user
$row = $usr->get_all_notif_of_user_connected();

if (empty($row))
{
  echo '{
	"data": [],
	"alert": {
		"color": "DarkBlue",
		"message": "There is no notification for u sorry !"
	}
}';
  return;
}
else
{
//print_r($row);
$string = '{
    "data" : [
      ';


foreach ($row as $key => $value) {
    // code...
    if ($row[$key]['readed'] == false)
      $readed = 'false';
    else
      $readed = 'true';

    $string .= '
    {
      "id" : '.$row[$key]['id_user'].',
      "content" : "'.$row[$key]['notification'].'",
      "date" : "'.$row[$key]['date_notif'].'",
      "unread" : '.$readed.'

        },
        ';
}
// ok je dois enlever la virgule ici

function enleve_virgule($string)
{
  $nbchar = strlen($string);
  $string = substr($string, 0, -10);

  $endofstring = '],
  "alert" : {
    "color" : "DarkGreen",
    "message" : "There the list of your notifications"
  }
  }';
  $string .= $endofstring;
  echo $string;
}
$usr->set_all_notif_readed();
enleve_virgule($string);
}
?>
