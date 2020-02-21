<?php
// id[int]

//
// var_dump($_POST);
// return;

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);

$row = $usr->get_all_details();

if ($row['gender'] == 1)
  $gender = 'Man';
else
  $gender = 'Woman';

if ($row['orientation'] == 0)
  $orientation = 'Bisexual';
else if ($row['orientation'] == 1)
  $orientation = 'Heterosexual';
else
  $orientation = 'Homosexual';

$rowpic = $usr->get_all_picture();

$rowtag = $usr->get_tag();
$output =' "tags" : [';
$x = 0;
foreach ($rowtag as $key => $value) {
  $x = 1;
  $output .=  '"'.$rowtag[$key]['tag'].'"';
  $output .= ', ';
}
if ($x == 1)
  $output = substr($output, 0 , -2);
$output .= ']';

//
// echo '{
//   "data" : {
//     "pseudo" : "'.$row['pseudo'].'",
//     "first_name" : "'.$row['lastname'].'",
//     "last_name" : "'.$row['firstname'].'",
//     "email" : "'.$row['email'].'",
//     "gender" : "'.$gender.'",
//     "orientation" : "'.$orientation.'",
//     "biography" : "Im good",
//     "birth" : "01-01-1970",
//     "pictures" :
//       [ { "id" : 1,
//           "path" : "https://images.unsplash.com/photo-1537886079430-486164575c54?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4c747db3353a34b312d05786f47930d3&auto=format&fit=crop&w=600&q=60"
//         }
//       , { "id" : 2,
//           "path" : "https://images.unsplash.com/photo-1537886194634-e6b923f92ff1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9eb2726071e58c1b0a430a75b1047525&auto=format&fit=crop&w=600&q=60"
//         }
//       , { "id" : 6,
//           "path" : "https://images.unsplash.com/photo-1537886243959-0b504cf58aa2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=1171ce40e6e68e663c3399a67a915913&auto=format&fit=crop&w=600&q=60"
//         }
//       , { "id" : 12,
//           "path" : "https://images.unsplash.com/photo-1537886492139-052c27acbfee?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=664282a4bd8b8a69cc860420214df3e7&auto=format&fit=crop&w=600&q=60"
//         }
//       , { "id" : 43,
//           "path" : "https://images.unsplash.com/photo-1537886464786-8a0d500b0da6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=49984d393482456ea5484c3482cc52a9&auto=format&fit=crop&w=600&q=60"
//         }
//       ],
//     "popularity_score" : 100,
//     "tags" : ["tag", "lovetags"]
//   },
//   "alert" : {
//     "color" : "DarkBlue",
//     "message" : "current settings alert"
//   }
// }';
//
// return;

echo '{
"data" : {
  "pseudo" : "'.$row['pseudo'].'",
  "last_name" : "'.$row['lastname'].'",
  "first_name" : "'.$row['firstname'].'",
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
  '.$output.'
},
"alert" : {
  "color" : "DarkBlue",
  "message" : "current settings alert"
}
}';



?>
