<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

try {
  $usr = new User('sosa', hash_password($pw), $db);
  $row = $usr->get_all_details();

} catch (\Exception $e) {
  echo '{
    "result" : "Failure",
    "message" : "'.$e->getMessage().'"
  }';
}

if ($row['is_loged'] == 1)
  $stringforlast_log = 'Now';
else {
  $stringforlast_log = $row['last_log'];
}

//
// reste a faire
//                        TAGS -- LIKED -- PICTURE
//
//
if ($row)
{
  echo '
  "result" : "Success",
  -- maybe "data" : {
    "id" : "'.$row['id'].'",
    "pseudo" : '.$row['pseudo'].',
    "first_name" : '.$row['firstname'].',
    "last_name" : '.$row['lastname'].',
    "gender" : '.$row['gender'].',
    "orientation" : "'.$row['orientation'].'",
    "biography" : "'.$row['biography'].'",
    "birth" : "'.$row['birth'].'",
    "last_log" : '.$stringforlast_log.',
    "is_loged" : "'.$row['is_loged'].'",
    "pictures" : ["/data/name.png", ...],
    "popularity_score" : "'.$row['popularity_score'].'",
    "tags" : ["#tag", ...],
    "liked" : "True" or "False"
  }
  -- maybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }';

}
else {
 echo '{
      "result" : "Failure",
      "message" : "An error occur to provide user s information."
    }';
}
?>
