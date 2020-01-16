<?php
//
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$obj = new User(5, $db);
$row = $obj->get_all_details();
//$lastmessage = $obj->get_last_message();

print_r($row);

if ($row['is_loged'] == 1)
{
  $toprint = 'Now';
}
else {
  $toprint = $row['last_log'];
}

echo '<br><br><br>';

echo
'{
  "result" : "Success",
   "message" : [
    {
      "id" : "'.$row['id_user'].'",
      "pseudo" : "'.$row['pseudo'].'",
      "picture" : "/data/name.png",
      "last_log" : '.$toprint.',
      "last_message" : "blabla!",
      "unread" : "True"
    }
  ]
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }';

//
//
// echo '{
//   "result" : "",
//   "message" : "sisi la famille"
// }';
?>
