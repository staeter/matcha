<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

$usr = unserialize($_SESSION['user']);

// fonction qui recupere toutes les notifs de tel ID_user
$row = $usr->get_all_notif_of_user_connected();
if (empty($row))
{
  echo 'c vide';
}
else
print_r($row);
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
