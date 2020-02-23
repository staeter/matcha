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


  function array_empty($a)
  {
      foreach($a as $k => $v)
          if(empty($v))
              return false;
      return true;
  }


// function gestion de la localisation

$array_gps = $usr->get_all_details();
$latitude_id_co = $array_gps['latitude'];
$longitude_id_co = $array_gps['longitude'];

function get_distance_m($lat1, $lng1, $lat2, $lng2) {
     $earth_radius = 6378137;   // Terre = sphère de 6378km de rayon
     $rlo1 = deg2rad($lng1);
     $rla1 = deg2rad($lat1);
     $rlo2 = deg2rad($lng2);
     $rla2 = deg2rad($lat2);
     $dlo = ($rlo2 - $rlo1) / 2;
     $dla = ($rla2 - $rla1) / 2;
     $a = (sin($dla) * sin($dla)) + cos($rla1) * cos($rla2) * (sin($dlo) * sin($dlo));
     $d = 2 * atan2(sqrt($a), sqrt(1 - $a));
     return ($earth_radius * $d);
   }

  //

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

foreach ($array as $key => $value)
  if ($row_to_clear[$key]['popularity_score'] >= $popularity_min && $row_to_clear[$key]['popularity_score'] <= $popularity_max)
      $array1[$key] = $row_to_clear[$key];


//gestion des distance en km ici
$distance_max_filtre = $_POST['distanceMax'];

foreach ($array1 as $key => $value) {
  // recuperer la valeur de longitude et latitude
$latitude = $array1[$key]['latitude'];
$longitude = $array1[$key]['longitude'];
$distance = (round(get_distance_m($latitude_id_co, $longitude_id_co, $latitude, $longitude) / 1000, 3)). ' km';

if ($distance <= $distance_max_filtre)
  $arrayaaa[$key] = $array1[$key];

}

//$array1 = array();
foreach ($arrayaaa as $key => $value) {
  $arraylili[$key] = $arrayaaa[$key];
}

$array1 =array();
foreach ($arraylili as $key => $value) {
  $array1[$key] = $arraylili[$key];
  // code...
}
// var_dump($array1);
// echo '<br><br>';
// return;
//
// if (!isset($arrayaicha))
// {
//   echo '{
//     "data" : {
//       "pageAmount" : 1,
//       "elemAmount" : 1,
//       "users" : []
//     },
//     "alert" : {
//       "color" : "DarkRed",
//       "message" : "There is no profil who match ur query of distance"
//     }
//   }';
//   return;
// }

//
// $array1 = array();
// foreach ($arrayaicha as $key => $value) {
//   $array1[$key] = $arrayaicha[$key];
// }
//
//
// var_dump($array1);
// return;


//

$profile_viewed = $_POST['viewed'];
$profile_liked = $_POST['liked'];

// var_dump($array1);
// return;

if ($_POST['tags'] != '[]')
{

  $string_tag = $_POST['tags'];
  $string_tag = substr($string_tag, 1, -1);

  $array_tag = explode(',', $string_tag);
  foreach ($array_tag as $key => $value) {
    $array_tag[$key] = substr($array_tag[$key], 1, -1);
  }

  foreach ($array_tag as $key => $value){
    $row[$key] = $usr->get_users_who_have_this_tag($array_tag[$key]);}


  if (array_empty($row) == false)
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who match ur query of TAGS"
      }
    }';
    return;
  }
// ok  jai donc row qui contient tout les occurence des id qui on like le tag
//$row[$key]['id_user'] =
  else {
     $array1 = array();
    foreach ($row as $key => $value) {
      $array1[$key] = $usr->get_all_details_of_this_id($row[$key][0]['id_user']);
    }
  }
}



if ($profile_viewed == 'True' && $profile_liked == 'False')
{
  //trier array 1 pour ne contenir que les raw contenant une occurence dans profile viewed

  $row_viewed = $usr->get_who_see_the_profil_of_user_connect();


  $array1 = array();

  foreach ($row_viewed as $key => $value) {
      $array1[$key] = $usr->get_all_details_of_this_id($row_viewed[$key]['id_user_viewing']);
  }
}
if (array_empty($array1) == false)
{
  echo '{
    "data" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : []
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "There is no profil who visit ur profile LOOSER"
    }
  }';
  return;
}


if ($profile_liked == 'True' && $profile_viewed == 'False')
{

  // je vais tenter une methode qui prend en compte le tri separement pour viewed & liked

  $row_like = $usr->get_who_liked_the_connected_user();

  // je retourne cette liste
$i = 0;
$array1 = array();
foreach ($row_like as $key => $value) {
  // code...
    $array1[$key] = $usr->get_all_details_of_this_id($row_like[$key]['id_user_liking']);
  }
// var_dump($arraysosa);
// echo '<br>';
// return;
}

if (array_empty($array1) == false)
{
  echo '{
    "data" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : []
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "There is no profil who liked ur profile LOOSER"
    }
  }';
  return;
}

if ($profile_liked == 'True' && $profile_viewed == 'True')
{
  echo '{
    "data" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : []
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "Select betwen viewed or liked, both isnt set yet(not asked by school)"
    }
  }';

  return;

}


//   $row_like = $usr->list_of_like_of_user_connected();
// //   var_dump($row_like);
// //   // row like contient un tableau des occurence de like entre des users et lui
// //
// //   echo '<br>';
// //   var_dump($row_to_clear);
// //   echo '<br>';
// // var_dump($array1);
//   // donc le tableau a renvoye doit contenir uniquement ces occurences la
//   $arrayc = array();
//
// //  var_dump($row_like);
//
// //  var_dump($array1);
//
//   foreach ($array1 as $key => $value) {
//     // if ($row_like[$key]['id_user_liking'] == $array1[$key]['id_user'] && $row_like[$key]['id_user_liked'] == 5)
//     // {
//     // $arrayc[$key] = $array1[$key];
//     //
//     // }
//       foreach ($row_like as $key => $value) {
//         if ($row_like[$key]['id_user_liking'] == $array1[$key]['id_user'] && $row_like[$key]['id_user_liked'] == 5)
//          {
//          $arrayc[$key] = $array1[$key];
//          }
//       }
//   }
//   var_dump($arrayc);
//   return;






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




// je verifie avant d envoyer le tableau qu il reste des occurences
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
//

// la je renvoi les occurences contenu dans array 1
$array1 = array_values($array1);

if (array_empty($array1) == false)
{
  echo '{
    "data" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : []
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "There is no profil who match with ur query"
    }
  }';
  return;
}
// var_dump($array1);
// return;

foreach ($array1 as $key => $value)
{
    $path = $usr->get_picture_profil($array1[$key]['id_user']);
    $liked = $usr->get_if_liked($array1[$key]['id_user']);
    // if($array1[$key]['id_user'] == $_SESSION['id'])
    //   $key++;
    if (!isset($array1[$key]['id_user']))
    {
        echo '{
          "data" : {
            "pageAmount" : 1,
            "elemAmount" : 1,
            "users" : []
          },
          "alert" : {
            "color" : "DarkRed",
            "message" : "There is no profil who liked ur profile LOOSER"
          }
        }';
        return;
    }
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

      $rowtag = $usr->get_tag_of_this_id($array1[$key]['id_user']);
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

      //  echo $array[$key]['id_user'];

    $string .= '{
      "id" : '.$array1[$key]['id_user'].',
      "pseudo" : "'.$array1[$key]['pseudo'].'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}
// echo ($string);
// return;

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
