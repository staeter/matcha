<?php
// id[int]


session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

$usr->add_popularity_of_this_user($_POST['id']);

$row = $usr->get_all_details_of_this_id($_POST['id']);
$x = $usr->get_if_liked($_POST['id']);
if ($x == true)
  $x = 'true';
else
  $x = 'false';

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


//en attendant
// il faudra pmettre a jour le gender & l orientation dans la bdd pour fixer ca
// reste aussi les pictures et les tags.

$usr->set_a_notif_for_profile_viewed($_POST['id']);
$usr->set_profile_viewed($_POST['id']);

$rowtag = $usr->get_tag();

  $output =' "tags" : [';
  $xxx = 0;
  foreach ($rowtag as $key => $value) {
    $xxx = 1;
    $output .=  '"'.$rowtag[$key]['tag'].'"';
    $output .= ', ';
  }
  if ($xxx == 1)
    $output = substr($output, 0 , -2);
  $output .= ']';

  $row_pic = $usr->get_all_picture_of_this_id($_POST['id']);

  $string = '[';
  foreach ($row_pic as $key => $value) {
    // code...
    $string .= '"'.$row_pic[$key]['path'].'", ';
  }
  $string = substr($string, 0, -2);
  $string .= ']';

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
  if ($row['is_loged'] == 1)
    $stringlog = 'Now';
  else
    $stringlog = $row['last_log'];

    $rowtag = $usr->get_tag_of_this_id($_POST['id']);
      $output =' "tags" : [';
      $xy = 0;
      foreach ($rowtag as $key => $value) {
        $xy = 1;
        $output .=  '"'.$rowtag[$key]['tag'].'"';
        $output .= ', ';
      }
      if ($xy == 1)
        $output = substr($output, 0 , -2);
      $output .= ']';

  echo '{
    "data" : {
      "id" : '.$row['id_user'].',
      "pseudo" : "'.$row['pseudo'].'",
      "first_name" : "'.$row['firstname'].'",
      "last_name" : "'.$row['lastname'].'",
      "gender" : "'.$gender.'",
      "orientation" : "'.$orientation.'",
      "biography" : "'.$row['biography'].'",
      "birth" : "'.$row['birth'].'",
      "last_log" : "'.$stringlog.'",
      "pictures" : '.$string.',
      "popularity_score" : '.$row['popularity_score'].',
      '.$output.',
      "liked" : '.$x.'
    },
    "alert" : {
      "color" : "DarkGreen",
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
