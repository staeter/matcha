<?php



session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');





// id[int]
/*
{
  "id" : 12,
  "pseudo" : "hisPseudo",
  "picture" : "/data/name.png",
  "last_log" : "Now" or "some date",
  "messages" : [
    {
      "direction" : "Sent" or "Received",
      "date" : "some date",
      "content" : "blablabla"
    },
    ...
  ]
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
