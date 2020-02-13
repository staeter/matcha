<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

$usr = unserialize($_SESSION['user']);


$count = $usr->get_count_notif_user_connected();



echo '{
  "data" : {
    "amount" : '.$count.'
  }
}';



//
//
// echo '{
//   "data" : {
//     "amount" : 234
//   }
// }';

?>
