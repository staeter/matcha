<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
// ob_start();
// var_dump($_POST);
// return;
// $result = ob_get_clean();
// error_log("[POST] feed_filter.php: " . $result);

///////////////////////////////////////////////
//
// array(8) {
  // ["ageMin"]=>
  // string(2) "16"
  // ["ageMax"]=>
  // string(3) "120"

  $age_min = $_POST['ageMin'];
  $age_max = $_POST['ageMax'];

  // je dois convertir age min & max en valeur AAAA-MM-JJ
  $date = date_create();
  date_sub($date, date_interval_create_from_date_string(' '.$age_min.' years'));
  $age_min = date_format($date, 'Y-m-d');


  $date = date_create();
  date_sub($date, date_interval_create_from_date_string(' '.$age_max.' years'));
  $age_max = date_format($date, 'Y-m-d');


  // je dois recuperer un tableau trier dont les users ont un age compris
  // entre
  // age min & age max
  $row_to_clear = $usr->get_all_details_of_all_id_between_age_min_max($age_max, $age_min);



  if (empty($row_to_clear))
    {
      echo '{
        "data" : {
          "pageAmount" : 1,
          "elemAmount" : 1,
          "users" : []
        },
        "alert" : {
          "color" : "DarkRed",
          "message" : "There is no profil who match ur query"
        }
      }';

      return;
    }
//foreach a faire a la fin

$string = '{
  "data" : {
    "pageAmount" : 1,
    "elemAmount" : 1,
    "users" : [';

//////////////////////////////////////////////////
// ici j enleve l occurence de l user connecté  //
$arrayx = array();
foreach ($row_to_clear as $key => $value) {
  if ($row_to_clear[$key]['id_user'] != $_SESSION['id'])
      $arrayx[$key] = $row_to_clear[$key];
}
foreach ($arrayx as $key => $value) {
  if ($arrayx[$key]['biography'] != NULL)
      $array[$key] = $arrayx[$key];}


/////////////////////////////////////////////////

// ["popularityMin"]=>
// string(2) "10"
// ["popularityMax"]=>
// string(3) "100"

$popularity_min = $_POST['popularityMin'];
$popularity_max = $_POST['popularityMax'];


$array1 = array();

foreach ($array as $key => $value) {
  if ($row_to_clear[$key]['popularity_score'] >= $popularity_min && $row_to_clear[$key]['popularity_score'] <= $popularity_max)
      $array1[$key] = $row_to_clear[$key];
}

$profile_viewed = $_POST['viewed'];
$profile_liked = $_POST['liked'];

// var_dump($array1);
// return;
if ($profile_viewed == 'true')
{
  //trier array 1 pour ne contenir que les raw contenant une occurence dans profile viewed
}



if ($profile_liked == 'True')
{
  $row_like = $usr->list_of_like_of_user_connected();
//   var_dump($row_like);
//   // row like contient un tableau des occurence de like entre des users et lui
//
//   echo '<br>';
//   var_dump($row_to_clear);
//   echo '<br>';
// var_dump($array1);
  // donc le tableau a renvoye doit contenir uniquement ces occurences la
$array1 = array();
  foreach ($row_like as $key => $value) {
    if ($row_like[$key]['id_user_liked'] == $row_to_clear[$key]['id_user'])
    $array1[$key] = $row_to_clear[$key];
  }

}





  //trier array 1 pour ne contenir que les raw contenant une occurence dans profile liked
  // foreach ($row_like as $key => $value) {
  //   if ($row_like[$key]['id_user_liked'] == $_SESSION['id'] || $row_like[$key]['id_user_liking'] == $_SESSION['id'])
  //   {
  //     print_r($row_like[$key]);
  //     print_r($array1[$key]);
  //       if ($row_like[$key]['id_user_liked'] == $array1[$key]['id_user'] || $row_like[$key]['id_user_liking'] == $array1[$key]['id_user'])
  //       {
  //         echo 'sosa aaaaa          ';
  //       }
  //   }
  //  }
if (empty($array1))
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who match ur query"
      }
    }';

    return;
  }

//////////// pour l instant je gere popularité & age min/max
///////////////////////////////////////////////////////////////////////
////////////////////// CE FOREACH RENVOI LE MSG JSON //////////////////

foreach ($array1 as $key => $value)
{

    $path = $usr->get_picture_profil($row_to_clear[$key]['id_user']);
    $liked = $usr->get_if_liked($row_to_clear[$key]['id_user']);
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

      $rowtag = $usr->get_tag_of_this_id($row_to_clear[$key]['id_user']);
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


    $string .= '{
      "id" : '.$array1[$key]['id_user'].',
      "pseudo" : "'.$array1[$key]['pseudo'].'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}


$string = substr($string, 0, -1);

$string .= ']
},
"alert" : {
"color" : "DarkBlue",
"message" : "feed filter call"
}
}';
echo $string;
return;


  // ["distanceMax"]=>
  // string(2) "76"
  // ["tags"]=>
  // string(15) "["sosa","reda"]"
  // ["viewed"]=>
  // string(5) "False"
  // ["liked"]=>
  // string(5) "False"

//
//
//
//
//////////////////////////////////////////////

echo '{
  "data" : {
    "pageAmount" : 1,
    "elemAmount" : 1,
    "users" : [
      {
        "id" : 1,
        "pseudo" : "John",
        "picture" : "/Pictures/addpic.png",
        "tags" : ["geek", "foot"],
        "liked" : false
      },
      {
        "id" : 3,
        "pseudo" : "Lise",
        "picture" : "/Pictures/addpic.png",
        "tags" : ["boty", "makup"],
        "liked" : false
      },
      {
        "id" : 12,
        "pseudo" : "Marcel",
        "picture" : "/Pictures/addpic.png",
        "tags" : ["tatoo", "beer"],
        "liked" : false
      },
      {
        "id" : 13,
        "pseudo" : "clara",
        "picture" : "/Pictures/addpic.png",
        "tags" : [],
        "liked" : false
      }
    ]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "feed filter call"
  }
}';
// ageMin[int] ageMax[int] distanceMax[int] popularityMin[int] popularityMax[int] tags[json array of strings] viewed[True/False] liked[True/False]
/*
{
  -- mamybe "data" : {
    "pageAmount" : 12,
    "elemAmount" : 12,
    "users" : [ // NB: only fully completed users accounts
      {
        "id" : 12,
        "pseudo" : "myPseudo",
        "picture" : "/data/name.png",
        "tags" : ["tag", ...],
        "liked" : true or false
      },
      ...
    ]
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

// NB: empty users list and alert if account not complete
?>
