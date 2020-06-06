<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

function array_empty($a)
{
  if ($a == NULL)
    return false;
  foreach ($a as $k => $v)
  {
      if(empty($v))
          return false;
  }
  return true;
}

function return_error($error)
{
  echo '{
    "data" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : []
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "'.$error.'"
    }
  }';
}

function get_distance($lat1, $lon1, $lat2, $lon2, $unit) 
{
  if (($lat1 == $lat2) && ($lon1 == $lon2)) 
  {
    return 0;
  }
  else 
  {
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

function get_distance_m($lat1, $lng1, $lat2, $lng2) 
{
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

$row_to_clear = $usr->get_all_details_of_all_id_between_age_min_max($age_max, $age_min);

if (array_empty($row_to_clear) == false)
{
  return_error("There is no profil who match with your query of Age min/max");
  return;
}

$string = '{
  "data" : {
    "pageAmount" : 1,
    "elemAmount" : 1,
    "users" : [';

// ici j enleve l occurence de l user connecté & ceux sans biographie //

foreach ($row_to_clear as $key => $value)
{
  if ($row_to_clear[$key]['id_user'] != $_SESSION['id'] && isset($row_to_clear[$key]['biography']))
      $array[$key] = $row_to_clear[$key];
}
if (isset($array))
  $tab = array_values($array);
if (array_empty($tab) == false)
{
  return_error("There is no profil except you wtf ? Recommend us for have more users^^");
  return;
}

$row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

if (array_empty($row_usr_blocked) == true)
{
  foreach ($row_usr_blocked as $key => $value) 
  {
    $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];
    foreach ($tab as $key => $value) 
    {
      if (isset($tab[$key]['id_user']) && $tab[$key]['id_user'] == $id_user_blocked)
      {
        $tab[$key] = NULL;
        break;
      }
    }
  }
}

foreach ($tab as $key => $value) 
{
  if ($tab[$key] == NULL)
    {
        unset($tab[$key]);
    }
}
$tab = array_values($tab);
if (array_empty($tab) == false)
{
  return_error("There is no profil who match with your query, try to modify value of age or u have block all users ^^");
  return;
}

$popularity_min = $_POST['popularityMin'];
$popularity_max = $_POST['popularityMax'];

foreach ($tab as $key => $value){
  if ($tab[$key]['popularity_score'] >= $popularity_min && $tab[$key]['popularity_score'] <= $popularity_max)
       $toclear[$key] = $tab[$key];}
$tab = NULL;
//var_dump($toclear);
if (isset($toclear))
  $tab = array_values($toclear);

if (array_empty($tab) == false)
{
  return_error("There is no profil who match with your query of Popularity Score");
  return;
}
//gestion des distance en km ici
$distance_max_filtre = $_POST['distanceMax'];
$compteur = 0;
foreach ($tab as $key => $value) 
{
    // recuperer la valeur de longitude et latitude
    $latitude = $tab[$key]['latitude'];
    $longitude = $tab[$key]['longitude'];
    $distance = round(get_distance($latitude_id_co, $longitude_id_co, $latitude, $longitude, "K"));

    if ($distance <= $distance_max_filtre)
      {
        $array_tab0[$compteur] = $tab[$key];
        $compteur++;
      }
}
if (!isset($array_tab0))
{
    return_error('No result whit ur filter KM/Popularity/Age');
    return;
}

$tab = array_values($array_tab0);

if (array_empty($tab) == false)
{
  return_error("There is no profil who match with your query of Distance");
  return;
}

// $profile_viewed = $_POST['viewed'];
// $profile_liked = $_POST['liked'];

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

  if (array_empty($row_tag_multidim) == false)
  {
    return_error("There is no profil who match with your query of Tags");
    return;
  }
  // print_r($row_tag_multidim);
  $i = 0;
  while (isset($row_tag_multidim[0][$i]['id_user']))
  {
    $aisha[$i] =  $row_tag_multidim[0][$i]['id_user'];
    $i++;
  }

  foreach ($aisha as $k => $value) 
  {
    foreach ($tab as $key => $value) 
    {
        if ($tab[$key]['id_user'] == $aisha[$k])
        {
          $row_to_return[$key] = $tab[$key];
          unset($tab[$key]);
        }
    }
  }
  $tab = NULL;
  if (!isset($row_to_return))
  { 
    return_error("There is no profil who match with your query of Tags");
    return;
  }
  $tab = array_values($row_to_return);

  //var_dump($row_to_return);
  // $i = 0;
  // while(isset($row_tag_multidim[$i]))
  //   $i++;

  // $raw_to_clean = $tab;
  // $index_tri = 0;
  // $fin_tri = 0;
  // while ($raw_to_clean[$fin_tri])
  //   $fin_tri++;

  // $index_tab = 0;

  // $start = 0;
  // $index = 0;
  // while ($start < $i)
  // {
  //   foreach ($row_tag_multidim[$start] as $key => $value) 
  //     $tab_ret[$index++] = $row_tag_multidim[$start][$key];
  //   $start++;
  // }

  // $tab = array();

  // while($index_tri < $fin_tri)
  // {
  //   foreach ($raw_to_clean as $key => $value) {
  //     if ($raw_to_clean[$key]['id_user'] == $tab_ret[$index_tab]['id_user'])
  //       $tab_to_unify[$index_tab] = $raw_to_clean[$key];
  //   }
  //   $index_tab++;
  //   $index_tri++;
  // }
 
  // $tab = super_unique($tab_to_unify, 'id_user');

}
// if ($profile_viewed == 'True' && $profile_liked == 'False')
// {
//   //trier array 1 pour ne contenir que les raw contenant une occurence dans profile viewed

//   $row_viewed = $usr->get_who_see_the_profil_of_user_connect();


//   if (array_empty($row_viewed) == false || empty($row_viewed))
//   {
//     echo '{
//       "data" : {
//         "pageAmount" : 1,
//         "elemAmount" : 1,
//         "users" : []
//       },
//       "alert" : {
//         "color" : "DarkRed",
//         "message" : "There is no profil who view ur profil sry"
//       }
//     }';
//     return;
//   }
//   foreach ($row_viewed as $key => $value) {
//       $arrayviewed[$key] = $usr->get_all_details_of_this_id($row_viewed[$key]['id_user_viewing']);
//   }

//   $tab = array();
//   foreach ($arrayviewed as $key => $value) {
//     $tab[$key] = $arrayviewed[$key];
//   }
// }
//   // print_r($tab);
//   // return;


// if ($profile_liked == 'True' && $profile_viewed == 'False')
// {

//   // je vais tenter une methode qui prend en compte le tri separement pour viewed & liked

//   $row_like = $usr->get_who_liked_the_connected_user();

//   // print_r($row_like);
//   // return;

//   if (array_empty($row_like) == false || empty($row_like))
//   {
//     echo '{
//       "data" : {
//         "pageAmount" : 1,
//         "elemAmount" : 1,
//         "users" : []
//       },
//       "alert" : {
//         "color" : "DarkRed",
//         "message" : "There is no profil who liked ur profile LOOSER"
//       }
//     }';
//     return;
//   }

//   // je retourne cette liste
//   $tab =array();

// foreach ($row_like as $key => $value) {
//   // code...
//     $tab[$key] = $usr->get_all_details_of_this_id($row_like[$key]['id_user_liking']);
//   }


//    $row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

//   if (array_empty($row_usr_blocked) == true)
//   {
//     foreach ($row_usr_blocked as $key => $value) {
//       // code...
//       $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];

//       foreach ($tab as $key => $value) {
//         if ($tab[$key]['id_user'] == $id_user_blocked)
//             {
//               $tab[$key] = NULL;
//               array_values($row);
//               break;
//           }
//         }
//     }

//   }
//   $tab = array_values($tab);

//   foreach ($tab as $key => $value) {
//     if ($tab[$key] == NULL)
//       {
//           unset($tab[$key]);
//       }
//     }
//     $tab = array_values($tab);

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
//           "message" : "There is no profil who match ur query 1111114"
//         }
//       }';

//       return;
//     }
// // var_dump($arraysosa);
// // echo '<br>';
// // return;
// }

// // print_r($tab);
// // return;

// if ($profile_liked == 'True' && $profile_viewed == 'True')
// {
//   echo '{
//     "data" : {
//       "pageAmount" : 1,
//       "elemAmount" : 1,
//       "users" : []
//     },
//     "alert" : {
//       "color" : "DarkRed",
//       "message" : "Select betwen viewed or liked, both isnt set yet(not asked by school)"
//     }
//   }';

//   return;

// }



// if (empty($tab) || array_empty($tab) == false)
//   {
//     echo '{
//       "data" : {
//         "pageAmount" : 1,
//         "elemAmount" : 1,
//         "users" : []
//       },
//       "alert" : {
//         "color" : "DarkRed",
//         "message" : "There is no profil who match ur query sosa"
//       }
//     }';

//     return;
//   }

// //////////// pour l instant je gere popularité & age min/max
// ///////////////////////////////////////////////////////////////////////
// ////////////////////// CE FOREACH RENVOI LE MSG JSON //////////////////
// //


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

$string = substr($string, 0, -1);
$string .= ']},
      "alert" : {
        "color" : "DarkGreen",
        "message" : "The result of your research"
      }
    }';
echo $string;
return;