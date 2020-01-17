<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');


try {
  $usr = new User($_POST['id'], $db);
  $row = $usr->get_all_details();

} catch (\Exception $e) {
  echo '{
 "result": "Failure",
 "message": "An error occur to provide user s information.",
 "alert": {
  "color": "DarkRed",
  "message": "The id asked is not valid"
}
}';
return;
}


//
// reste a faire
//                        TAGS -- LIKED -- PICTURE
//
//

if (isset($row))
{
  if ($row['is_loged'] == 1)
    $stringforlast_log = 'Now';
  else {
    $stringforlast_log = $row['last_log'];
  }

  if (empty($row['gender']))
    $stringforgender = 'Non renseigné';
  else
    $stringforgender = $row['gender'];

  if (empty($row['orientation']))
      $stringfororientation = 'Non renseigné';
  else
      $stringfororientation = $row['orientation'];

  if (empty($row['biography']))
      $stringforbio = 'Non renseigné';
  else
      $stringforbio = $row['biography'];

  echo '{
  "data" : {
	"id" : "'.$row['id_user'].'",
	"pseudo" : "'.$row['pseudo'].'",
	"first_name" : "'.$row['firstname'].'",
	"last_name" : "'.$row['lastname'].'",
	"gender" : "'.$stringforgender.'",
	"orientation" : "'.$stringfororientation.'",
	"biography" : "'.$stringforbio.'",
	"birth" : "11-11-2011",
	"last_log": "'.$stringforlast_log.'",
  "pictures" : ["/data/name.png", "/data/pic2.png"],
	"is_loged": "'.$row['is_loged'].'",
	"popularity_score" : "'.$row['popularity_score'].'",
  "tags" : ["joy", "stuff"],
  "liked" : false
        },
  "alert" : {
      "color" : "DarkGreen",
      "message" : "usr info received"
        }
      }';
}
else {
 echo '{
"result": "Failure",
"message": "An error occur to provide user s information.",
"alert": {
 "color": "DarkRed",
 "message": "Cant get information of the user the row who must contain all info do not exist"}
}';
}
?>
