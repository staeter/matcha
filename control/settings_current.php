<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
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
