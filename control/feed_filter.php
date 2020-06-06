<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);


function super_unique($array,$key)
{
    $temp_array = [];
    foreach ($array as &$v) {
      if (!isset($temp_array[$v[$key]]))
          $temp_array[$v[$key]] =& $v;
      }
    $array = array_values($temp_array);
    return $array;
}

function array_empty($a)
{
    foreach($a as $k => $v)
      if(empty($v))
        return false;
    return true;
}
// function gestion de la localisation

function get_distance($lat1, $lon1, $lat2, $lon2, $unit) {
  if (($lat1 == $lat2) && ($lon1 == $lon2)) {
    return 0;
  }
  else {
    $theta = $lon1 - $lon2;
    $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
    $dist = acos($dist);
    $dist = rad2deg($dist);
    $miles = $dist * 60 * 1.1515;
    $unit = strtoupper($unit);

    if ($unit == "K") {
      return ($miles * 1.609344);
    } else if ($unit == "N") {
      return ($miles * 0.8684);
    } else {
      return $miles;
    }
  }
}



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


  $array_gps = $usr->get_all_details();
  $latitude_id_co = $array_gps['latitude'];
  $longitude_id_co = $array_gps['longitude'];


  $age_min = round($_POST['ageMin']);
  $age_max = round($_POST['ageMax']);

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


//
//row to cleat OOK
//


  if (array_empty($row_to_clear) == false || empty($row_to_clear))
    {
      echo '{
        "data" : {
          "pageAmount" : 1,
          "elemAmount" : 1,
          "users" : []
        },
        "alert" : {
          "color" : "DarkRed",
          "message" : "There is no profil who match ur query of age min/max"
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

foreach ($row_to_clear as $key => $value) {
  if ($row_to_clear[$key]['id_user'] != $_SESSION['id'])
      $arrayx[$key] = $row_to_clear[$key];
}

foreach ($arrayx as $key => $value) {
  if ($arrayx[$key]['biography'] != NULL)
      $array[$key] = $arrayx[$key];}


      $tab = array_values($array);

      foreach ($tab as $key => $value) {
        if ($tab[$key] == NULL)
          {
              unset($tab[$key]);
          }
        }
        $tab = array_values($tab);
        // print_r($tab);
        // return;
        //


$row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

if (array_empty($row_usr_blocked) == true)
{
  foreach ($row_usr_blocked as $key => $value) {
    // code...
    $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];

    foreach ($tab as $key => $value) {
      if (isset($tab[$key]['id_user']) && $tab[$key]['id_user'] == $id_user_blocked)
          {
            $tab[$key] = NULL;
           // array_values($row);
            break;
        }
      }
  }

}
$tab = array_values($tab);

foreach ($tab as $key => $value) {
  if ($tab[$key] == NULL)
    {
        unset($tab[$key]);
    }
  }
  $tab = array_values($tab);

if (array_empty($tab) == false || empty($tab))
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who match ur query try to stop block user"
      }
    }';

    return;
  }
//foreach a faire a

// print_r($tab);
// return;
//
  //ici c ok
  // j ai un tableau a l index verifier
/////////////////////////////////////////////////

// ["popularityMin"]=>
// string(2) "10"
// ["popularityMax"]=>
// string(3) "100"

$popularity_min = $_POST['popularityMin'];
$popularity_max = $_POST['popularityMax'];
$array1 = array();
foreach ($tab as $key => $value)
  if ($tab[$key]['popularity_score'] >= $popularity_min && $tab[$key]['popularity_score'] <= $popularity_max)
      $array1[$key] = $tab[$key];


$tab = array_values($array1);
//ICI CA MARCHE





//SOSA
foreach ($tab as $key => $value) {
  if ($tab[$key] == NULL)
      {
        unset($tab[$key]);
      }
  }
  $tab = array_values($tab);

  if (array_empty($tab) == false)
  {
            echo '{
              "data" : {
                "pageAmount" : 1,
                "elemAmount" : 1,
                "users" : []
              },
              "alert" : {
                "color" : "DarkRed",
                "message" : "There is no profil who match ur query of popularity score"
              }
            }';
      return;
  }

  // print_r($tab);
  // return;

//////DERNIER TEST REUSSI ICI


//gestion des distance en km ici
$distance_max_filtre = $_POST['distanceMax'];

//
$array_tab = array();
foreach ($tab as $key => $value) {
    // recuperer la valeur de longitude et latitude
    $latitude = $tab[$key]['latitude'];
    $longitude = $tab[$key]['longitude'];
    //$distance = (round(get_distance_m($latitude_id_co, $longitude_id_co, $latitude, $longitude) / 1000));

    $distance = round(get_distance($latitude_id_co, $longitude_id_co, $latitude, $longitude, "K"));

    // echo $distance;
    // echo '///' . $distance_max_filtre . '<br>';
    //
    // echo '<br>';
    if ($distance <= $distance_max_filtre)
      {$array_tab[$key] = $tab[$key];}
}
// echo 'sosa';


// aray_tab contient tout les users a moins de $distance_max_filtre km
//

//faire un array values ici


foreach ($array_tab as $key => $value) {
  if ($array_tab[$key] == NULL)
    {
        unset($array_tab[$key]);
    }
  }
  $tab = array_values($array_tab);

//
// print_r($tab);
// return;




if (array_empty($tab) == false || empty($tab))
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who match ur query with distance"
      }
    }';

    return;
  }


//   // echo 'sosa<br>';
//   // var_dump($array_tab);
//   // return;
//
// $tab = NULL;

//
//
//
//   if (array_empty($tab) == false || empty($tab))
//     {
//       echo '{
//         "data" : {
//           "pageAmount" : 1,
//           "elemAmount" : 1,
//           "users" : []
//         },
//         "alert" : {
//           "color" : "DarkRed",
//           "message" : "There is no profil who match ur query of distance"
//         }
//       }';
//
//       return;
//     }
// donc distance gerer
// ----> distance min max ok


/////////RESTE

//////////----->TAGS OOOOK
//-------------->VIEWED
///------------->LIKED
////////////////////////////////////



$profile_viewed = $_POST['viewed'];
$profile_liked = $_POST['liked'];

if ($_POST['tags'] != '[]')
{
  $string_tag = $_POST['tags'];
  $string_tag = substr($string_tag, 1, -1);

  $array_tag = explode(',', $string_tag);
  foreach ($array_tag as $key => $value) {
    $array_tag[$key] = substr($array_tag[$key], 1, -1);
  }

  foreach ($array_tag as $key => $value){
    $row_tag_multidim[$key] = $usr->get_users_who_have_this_tag($array_tag[$key]);}

//
// print_r($row_tag_multidim);
// return;

  if (array_empty($row_tag_multidim) == false)
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


$i = 0;

while($row_tag_multidim[$i])
  $i++;


  $raw_to_clean = $tab;
  // print_r($tab_ret);
  // return;
  $index_tri = 0;
  $fin_tri = 0;
  while ($raw_to_clean[$fin_tri])
    $fin_tri++;

  $index_tab = 0;

//echo $fin_tri;
$start = 0;
$index = 0;
while ($start < $i)
{
  foreach ($row_tag_multidim[$start] as $key => $value) {
    $tab_ret[$index++] = $row_tag_multidim[$start][$key];

  }
$start++;
}

$tab = array();

  while($index_tri < $fin_tri)
  {
    foreach ($raw_to_clean as $key => $value) {
      if ($raw_to_clean[$key]['id_user'] == $tab_ret[$index_tab]['id_user'])
        $tab_to_unify[$index_tab] = $raw_to_clean[$key];
    }
    $index_tab++;
    $index_tri++;
  }
  // print_r($tab_to_unify);
  // return;

  $tab = super_unique($tab_to_unify, 'id_user');

// print_r($tab);
// return;

// $taille = 0;
// $xx = 0;
// while($taille < $i)
// {
//
//   $j = 0;
//   while(isset($row_tag_multidim[$i][$j][id_user]))
//     {
//
//     $arrayredaa[$xx] = $row_tag_multidim[$i][$j];
//     $j++;
//
//     }
//     $taille++;
//     $i = 0;
// while ($row_tag_multidim[$i])
//   $i++;
//
//
//
//
//
// }

  //$row_tag_multidim = array_merge($row_tag_multidim);

// $tabss = super_unique($tab, 'id_user');
//   var_dump($tabss);
//   return;

// ok  jai donc row qui contient tout les occurence des id qui on like le tag
//$row[$key]['id_user'] =
//   else {
//
// foreach ($row as $key => $value)
// {
//   foreach ($row[$key] as $key1 => $value) {
//     $array1[$key1] = $usr->get_all_details_of_this_id($row[$key1]['id_user']);
//   }

}

// print_r($array1);
// return;
//   }
// }

//$tab = super_unique($array1, 'id_user');

//
// print_r($tab);
// return;


if ($profile_viewed == 'True' && $profile_liked == 'False')
{
  //trier array 1 pour ne contenir que les raw contenant une occurence dans profile viewed

  $row_viewed = $usr->get_who_see_the_profil_of_user_connect();


  if (array_empty($row_viewed) == false || empty($row_viewed))
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who view ur profil sry"
      }
    }';
    return;
  }
  foreach ($row_viewed as $key => $value) {
      $arrayviewed[$key] = $usr->get_all_details_of_this_id($row_viewed[$key]['id_user_viewing']);
  }

  $tab = array();
  foreach ($arrayviewed as $key => $value) {
    $tab[$key] = $arrayviewed[$key];
  }
}
  // print_r($tab);
  // return;


if ($profile_liked == 'True' && $profile_viewed == 'False')
{

  // je vais tenter une methode qui prend en compte le tri separement pour viewed & liked

  $row_like = $usr->get_who_liked_the_connected_user();

  // print_r($row_like);
  // return;

  if (array_empty($row_like) == false || empty($row_like))
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

  // je retourne cette liste
  $tab =array();

foreach ($row_like as $key => $value) {
  // code...
    $tab[$key] = $usr->get_all_details_of_this_id($row_like[$key]['id_user_liking']);
  }


   $row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

  if (array_empty($row_usr_blocked) == true)
  {
    foreach ($row_usr_blocked as $key => $value) {
      // code...
      $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];

      foreach ($tab as $key => $value) {
        if ($tab[$key]['id_user'] == $id_user_blocked)
            {
              $tab[$key] = NULL;
              array_values($row);
              break;
          }
        }
    }

  }
  $tab = array_values($tab);

  foreach ($tab as $key => $value) {
    if ($tab[$key] == NULL)
      {
          unset($tab[$key]);
      }
    }
    $tab = array_values($tab);

  if (array_empty($tab) == false || empty($tab))
    {
      echo '{
        "data" : {
          "pageAmount" : 1,
          "elemAmount" : 1,
          "users" : []
        },
        "alert" : {
          "color" : "DarkRed",
          "message" : "There is no profil who match ur query 1111114"
        }
      }';

      return;
    }
// var_dump($arraysosa);
// echo '<br>';
// return;
}

// print_r($tab);
// return;

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


  //renommage array viewed en tab



// // je verifie avant d envoyer le tableau qu il reste des occurences
// print_r($tab);
// return;

if (empty($tab) || array_empty($tab) == false)
  {
    echo '{
      "data" : {
        "pageAmount" : 1,
        "elemAmount" : 1,
        "users" : []
      },
      "alert" : {
        "color" : "DarkRed",
        "message" : "There is no profil who match ur query sosa"
      }
    }';

    return;
  }

//////////// pour l instant je gere popularité & age min/max
///////////////////////////////////////////////////////////////////////
////////////////////// CE FOREACH RENVOI LE MSG JSON //////////////////
//


foreach ($tab as $key => $value)
{

    $id = $tab[$key]['id_user'];
    $pseudo = $tab[$key]['pseudo'];

    $path = $usr->get_picture_profil($id);
    $liked = $usr->get_if_liked($id);


    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

      $rowtag = $usr->get_tag_of_this_id($id);
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
      "id" : '.$id.',
      "pseudo" : "'.$pseudo.'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}
// echo ($string);
// return;

$string = substr($string, 0, -1);

$string .= ']
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
?>
