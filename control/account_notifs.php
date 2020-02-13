<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

$usr = unserialize($_SESSION['user']);



// fonction qui recupere toutes les notifs de tel ID_user
$row = $usr->get_all_notif_of_user_connected();
//var_dump($row);

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


    // $findestring = '
    //   ]
    // },
    //   "alert" : {
    //   "color" : "DarkBlue",
    //   "message" : "chat discution alert"
    // }
    // }';

    //
  //   $string1 .= $findestring;
  $string .= $endofstring;
  echo $string;



//    echo $string1;

}

enleve_virgule($string);



}
// mtn j affiche le msg formaté en json

// ok mtn methode fait comme les autres pour formater en message json
// par contre je dois rajouter au moins reaed dans bdd table notif & par facilité date OK C FAIT



//
// echo '{
//   "data" : [
//     {
//       "id" : 12,
//       "content" : "somebody did something v1",
//       "date" : "01-01-2020",
//       "unread" : true
//     },
//     {
//       "id" : 13,
//       "content" : "somebody did something v4",
//       "date" : "12-08-2017",
//       "unread" : true
//     },
//     {
//       "id" : 20,
//       "content" : "somebody did something v14",
//       "date" : "12-05-2016",
//       "unread" : false
//     },
//     {
//       "id" : 1,
//       "content" : "somebody did something v23",
//       "date" : "12-05-2013",
//       "unread" : false
//     }
//   ],
//   "alert" : {
//     "color" : "DarkBlue",
//     "message" : "account notifs alert"
//   }
// }';

?>
