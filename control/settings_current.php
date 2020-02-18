<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);

$row = $usr->get_all_details();

// echo '{
//   "data" : {
//     "pseudo" : "'.$row['pseudo'].'",
//     "first_name" : "'.$row['firstname'].'",
//     "last_name" : "'.$row['lastname'].'",
//     "email"  : "'.$row['email'].'",
//     "gender" : "'.$row['gender'].'",
//     "orientation" : "'.$row['orientation'].'",
//     "biography" : "'.$row['biography'].'",
//     "birth" : "'.$row['birth'].'",
//     "pictures" : ["/data/name.png", "/data/pic2.png"],
//     "popularity_score" : '.$row['popularity_score'].',
//     "tags" : ["joy", "stuff"],
//   },
//   "alert" : {
//     "color" : "DarkBlue",
//     "message" : "Current setting alert"
//   }
// }';


////

if ($row['gender'] == 1)
  $gender = 'man';
else
  $gender = 'woman';

if ($row['orientation'] == 0)
  $orientation = 'bisexual';
else if ($row['orientation'] == 1)
  $orientation = 'heterosexual';
else
  $orientation = 'homosexual';

////

//
// ******************** I NEED SOME FUNCTION HERE FOR GET the id picture and path
//

$rowpic = $usr->get_all_picture();

echo '{
"data" : {
  "pseudo" : "'.$row['pseudo'].'",
  "first_name" : "'.$row['firstname'].'",
  "last_name" : "'.$row['lastname'].'",
  "email" : "'.$row['email'].'",
  "gender" : "'.$gender.'",
  "orientation" : "'.$orientation.'",
  "biography" : "'.$row['biography'].'",
  "birth" : "'.$row['birth'].'",
  "pictures" :
    [ { "id" : '.$rowpic[0]['id_picture'].',
        "path" :"'.$rowpic[0]['path'].'"
      }
    , { "id" : '.$rowpic[1]['id_picture'].',
        "path" :"'.$rowpic[1]['path'].'"
      }
    , { "id" : '.$rowpic[2]['id_picture'].',
        "path" :"'.$rowpic[2]['path'].'"
      }
    , { "id" : '.$rowpic[3]['id_picture'].',
        "path" :"'.$rowpic[3]['path'].'"
      }
    , { "id" : '.$rowpic[4]['id_picture'].',
        "path" :"'.$rowpic[4]['path'].'"
      }
    ],
  "popularity_score" : '.$row['popularity_score'].',
  "tags" : []
},
"alert" : {
  "color" : "DarkBlue",
  "message" : "current settings alert"
}
}';



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
