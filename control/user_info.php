<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

//$usr = unserialize($_SESSION['user']);
try {

$usr = new User($_POST['id'], $db);
$row = $usr->get_all_details();

$x = $usr->get_if_liked($_POST['id']);

if ($x == true)
  $x = 'true';
else {
  $x = 'false';
}

} catch (\Exception $e) {

  // message d erreur non pris en compte car elm attend un field avec data
  echo '{
  "data": {},
  "alert": {
  "color": "DarkRed",
  "message": "Cant get information because user DOESNT EXISTS"}
 }';
 return;
}



//
// reste a faire
//                        TAGS -- LIKED -- PICTURE
//
//        Probleme de bdd & de donnée attendu pour GENDER & ORIENTATION bdd prend des int

if (isset($row))
{
  if ($row['is_loged'] == 1)
    $stringforlast_log = 'Now';
  else {
    $stringforlast_log = $row['last_log'];
  }
  //$row['orientation'] = '';
  if (empty($row['biography']))
  {
    echo '{
    "data": {},
    "alert": {
    "color": "DarkRed",
    "message": "Cant get information because user didnt give it"}
   }';
   return;
  }


  // echo '{
  // "data" : {
	// "id" : '.$row['id_user'].',
	// "pseudo" : '.$row['pseudo'].',
	// "first_name" : '.$row['firstname'].',
	// "last_name" : '.$row['lastname'].',
	// "gender" : '.$stringforgender.',
	// "orientation" : '.$stringfororientation.',
	// "biography" : '.$stringforbio.',
	// "birth" : "11-11-2011",
	// "last_log": '.$stringforlast_log.',
  // "pictures" : ["/data/name.png", "/data/pic2.png"],
	// "is_loged": '.$row['is_loged'].',
	// "popularity_score" : '.$row['popularity_score'].',
  // "tags" : ["joy", "stuff"],
  // "liked" : false
  //       },
  // "alert" : {
  //     "color" : "DarkGreen",
  //     "message" : "usr info received"
  //       }
  //     }';

//

//en attendant
// il faudra pmettre a jour le gender & l orientation dans la bdd pour fixer ca
// reste aussi les pictures et les tags.

$usr->set_a_notif_for_profile_viewed($_POST['id']);


  echo '{
    "data" : {
      "id" : '.$row['id_user'].',
      "pseudo" : "'.$row['pseudo'].'",
      "first_name" : "'.$row['firstname'].'",
      "last_name" : "'.$row['lastname'].'",
      "gender" : "Man",
      "orientation" : "Bisexual",
      "biography" : "'.$row['biography'].'",
      "birth" : "'.$row['birth'].'",
      "last_log" : "'.$row['last_log'].'",
      "pictures" : ["/Pictures/rick.png"],
      "popularity_score" : '.$row['popularity_score'].',
      "tags" : ["joy", "stuff"],
      "liked" : '.$x.'
    },
    "alert" : {
      "color" : "DarkBlue",
      "message" : "usr info received"
    }
  }';
}
else {
 echo '{
"data": {},
"alert": {
 "color": "DarkRed",
 "message": "Cant get information of the user the row who must contain all info do not exist"
}
}';
}
?>
