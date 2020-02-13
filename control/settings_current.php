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

echo '{
"data" : {
  "pseudo" : "'.$row['pseudo'].'",
  "first_name" : "'.$row['firstname'].'",
  "last_name" : "'.$row['lastname'].'",
  "email" : "'.$row['email'].'",
  "gender" : "Man",
  "orientation" : "Bisexual",
  "biography" : "'.$row['biography'].'",
  "birth" : "01-01-1970",
  "pictures" :
    [ { "id" : 1,
        "path" : "https://images.unsplash.com/photo-1537886079430-486164575c54?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4c747db3353a34b312d05786f47930d3&auto=format&fit=crop&w=600&q=60"
      }
    , { "id" : 2,
        "path" : "https://images.unsplash.com/photo-1537886194634-e6b923f92ff1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9eb2726071e58c1b0a430a75b1047525&auto=format&fit=crop&w=600&q=60"
      }
    , { "id" : 6,
        "path" : "https://images.unsplash.com/photo-1537886243959-0b504cf58aa2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=1171ce40e6e68e663c3399a67a915913&auto=format&fit=crop&w=600&q=60"
      }
    , { "id" : 12,
        "path" : "https://images.unsplash.com/photo-1537886492139-052c27acbfee?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=664282a4bd8b8a69cc860420214df3e7&auto=format&fit=crop&w=600&q=60"
      }
    , { "id" : 43,
        "path" : "https://images.unsplash.com/photo-1537886464786-8a0d500b0da6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=49984d393482456ea5484c3482cc52a9&auto=format&fit=crop&w=600&q=60"
      }
    ],
  "popularity_score" : 100,
  "tags" : ["tag", "lovetags"]
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
