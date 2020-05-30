<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row = $usr->get_all_details();

if($row['pref_localisation'] == false)
  $string_loc = 'false';
else
    $string_loc = 'true';


$int_latitude = $row['longitude'];
$int_longitude = $row['latitude'];


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
$strpic = '';
foreach ($rowpic as $value) {
  $strpic .= '{ "id" : ' . $value['id_picture'] . ',
                "path" :"' . $value['path'] . '"
              },';
}
$strpic = substr($strpic, 0, -1);

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
  "pseudo" : "' . $row['pseudo'] . '",
  "last_name" : "' . $row['lastname'] . '",
  "first_name" : "' . $row['firstname'] . '",
  "email" : "' . $row['email'] . '",
  "gender" : "' . $gender . '",
  "orientation" : "' . $orientation . '",
  "biography" : "' . $row['biography'] . '",
  "birth" : "' . $row['birth'] . '",
  "pictures" :
    [ ' . $strpic . '
    ],
  "popularity_score" : ' . $row['popularity_score'] . ',
  ' . $output . ',
  "geoAuth" : ' . $string_loc . ',
  "latitude" : ' . $int_latitude . ',
  "longitude" : ' . $int_longitude . '
}
}';



?>
