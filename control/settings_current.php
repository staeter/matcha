<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);

$row = $usr->get_all_details();

echo '{
  "data" : {
    "pseudo" : "'.$row['pseudo'].'",
    "first_name" : "'.$row['firstname'].'",
    "last_name" : "'.$row['lastname'].'",
    "email"  : "'.$row['email'].'",
    "gender" : "'.$row['gender'].'",
    "orientation" : "'.$row['orientation'].'",
    "biography" : "'.$row['biography'].'",
    "birth" : "'.$row['birth'].'",
    "pictures" : ["/data/name.png", "/data/pic2.png"],
    "popularity_score" : '.$row['popularity_score'].',
    "tags" : ["joy", "stuff"],
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "Current setting alert"
  }
}';
//
// echo '{
//   "data" : {
//     "pseudo" : "myPseudo",
//     "first_name" : "John",
//     "last_name" : "Doe",
//     "email" : "Doe@gmail.com",
//     "gender" : "Man",
//     "orientation" : "Bisexual",
//     "biography" : "Im good",
//     "birth" : "01-01-1970",
//     "pictures" : ["/data/pic1.png", "/data/pic2.png", "/data/pic3.png"],
//     "popularity_score" : 100,
//     "tags" : ["#tag", "lovetags"]
//   },
//   "alert" : {
//     "color" : "DarkBlue",
//     "message" : "current settings alert"
//   }
// }';



?>