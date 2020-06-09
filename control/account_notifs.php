<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';

function enleve_virgule($string)
{
  $string = substr($string, 0, -11); 
  $endofstring = '],
  "alert" : {
    "color" : "DarkGreen",
    "message" : "There the list of your notifications"
  }
  }';
  $string .= $endofstring;
  echo $string;
}

$usr = unserialize($_SESSION['user']);
$row = $usr->get_all_notif_of_user_connected();

if (empty($row))
{
  echo '
  {
	  "data": [],
    "alert": 
    {
		  "color": "DarkBlue",
		  "message": "There is no notification !"
	  }
  }';
  return;
}
else
{
  $string = '{
    "data" : [
      ';

  foreach ($row as $key => $value) 
  {
    if ($row[$key]['readed'] == false)
      $readed = 'false';
    else
      $readed = 'true';

    $string .= '
    {
      "id" : '.$row[$key]['id_user'].',
      "content" : "'.$row[$key]['notification'].'",
      "date" : "'.$row[$key]['date'].'",
      "unread" : '.$readed.'

        },
        ';
  }
  $usr->set_all_notif_readed();
  enleve_virgule($string);
}
