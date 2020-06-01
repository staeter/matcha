<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';





$usr = unserialize($_SESSION['user']);



// $x = get_client_ip();

// //var_dump($x);
// var_dump($x);

//  print_r($x['postal']);
//echo $x["loc"];

// if (empty($_POST['password']) || empty($_POST['confirm']))
// {
//     echo '{
//       "result" : "Failure",
//       "message" : "Vous devez remplir tout les champs."
//     }';
// }

// if (strcmp($_POST['oldpw'], $_POST['newpw']) !== 0)
// {
//   echo '{
//     "result" : "Failure",
//     "message" : "Passwords doesnt match."
//   }';
// }
// else {
//

//   //
//    try {
//
//      if ($usr->set_picture('yo'))
//       echo 'nice';
//     else {
//       echo 'mzi';
//     }
//    } catch (\Exception $e) {
//      echo $e->getMessage();
//    }

//echo 'yo sosa sksks';

// //$usr->set_picture();
// echo '<br>salut<br>';echo '<br>salut<br>';
//
// echo '<br><br>';
// $id_pic = 1;
// //
// $row = $usr->get_all_details_of_all_id_between_age_min_max("2000-01-01", "2020-01-01");
// print_r($row);
//
// echo '<br>salutsss<br>';
//
// $age_min = 10;
// $date = date_create();
// date_sub($date, date_interval_create_from_date_string(' '.$age_min.' years'));
// $date = date_format($date, 'Y-m-d');
//
// echo $date;
// // $age_min2 = date('(Y - 16)-m-d');
// // //
// // // echo $age_min2;
// //
// // $yearnow= date("Y");
// // $yearnext=$yearnow+1;
// // echo date("Y")."-".$yearnext;
//
// //echo $row;
// return;
// $age_min = 3;
// $age_max = 120;
// $date = date_create();
// date_sub($date, date_interval_create_from_date_string(' '.$age_min.' years'));
// $age_min = date_format($date, 'Y-m-d');
//
//
// $date = date_create();
// date_sub($date, date_interval_create_from_date_string(' '.$age_max.' years'));
// $age_max = date_format($date, 'Y-m-d');
//
// echo $age_min;
// echo '<br><br>';
// echo $age_max;

// je dois recuperer un tableau trier dont les users ont un age compris
// entre
// age min & age max

// $popularity_min = 1;
// $popularity_max = 100;
//
//
// $row_to_clear = $usr->get_all_details_of_all_id_between_age_min_max($age_max, $age_min);
//
// $array = array();
// foreach ($row_to_clear as $key => $value) {
//
//   if ($row_to_clear[$key]['id_user'] != $_SESSION['id'])
//     {
//       $array[$key] = $row_to_clear[$key];
//     }
//
// }

// echo 'salut<br>sosa<br>loca<br><br>';
// print_r($array);
// return;
//
// $string = '{
//   "data" : {
//     "pageAmount" : 1,
//     "elemAmount" : 1,
//     "users" : [';

// foreach ($row_to_clear as $key => $value)
// {
//     // code...
//     $string .= '{
//       "id" : '.$row_to_clear[$key]['id_user'].',
//       "pseudo" : "'.$row_to_clear[$key]['pseudo'].'",
//       "picture" : "/Pictures/addpic.png",
//       "tags" : ["geek", "foot"],
//       "liked" : false
//     },';
// }
//
// $string .= ']
// },
// "alert" : {
// "color" : "DarkBlue",
// "message" : "feed filter call"
// }
// }';
//
// echo $string;
// return;
// echo $string;

$i = 0;
$string = "so sosa  s      s         ";
// $x = 0;
// while($string[$i])
// {
//   if ($string[$i] == ' ')
//     $x = 1;
//   $i++;
// }
// if ($x == 0)
// {
//   // mettre
// $string = trim($string);
// $array = explode(" ", $string);
//
// //foreach valeur mettre dans la bcadd
//
// foreach ($array as $key => $value) {
//   if ($array[$key] != '')
//   {
//
//     $x =  $usr->get_if_tag_already_set($array[$key]);
//     var_dump($x);
//
//     if ($x["COUNT(*)"] == '0')
//     {
//       $usr->set_tag($array[$key]);
//        // echo '<br>' . $s . '<br>';
//       // var_dump($s);
//     }
//         //les tags sont trier
//     // faudra gerer la supression des tags avant l insertion
//     // en plus faut tcheck si le tags est pas deja mis
//     //donc mettre le tags ici si il n existe pas deja dans la bdd
//     // if ($usr->get_if_tag_already_set($array[$key]) == FALSE)
//     // {
//     //   echo 'on entre';
//     //     $x = $usr->set_tag($array[$key]);
//     //     echo '<br>' . $x . '<br>';
//     // }
//     // $r = $usr->get_if_tag_already_set('sos');
//     // var_dump($r);
//   // echo $array[$key];
//   echo '<br>';
//   // echo $_SESSION['id'];
//   }
// }
// $ra = $usr->get_tag();
// //print_r($ra);
// $output =' "tags" : [';
//
// foreach ($ra as $key => $value) {
//   $output .=  '"'.$ra[$key]['tag'].'"';
//   $output .= ', ';
// }
//
// $output = substr($output, 0 , -2);
// $output .= ']';
// echo $output;
// $row_pic = $usr->get_all_picture_of_this_id(6);
//
// $string = '[';
// foreach ($row_pic as $key => $value) {
//   // code...
//   $string .= '"'.$row_pic[$key]['path'].'", ';
// }
// $string = substr($string, 0, -2);
// $string .= ']';
//var_dump($array);
// echo $string;;

// // $row = $usr->get_gender();
// print_r($row);

// $usr->set_sexuality_orientation(2);
// function get_distance_m($lat1, $lng1, $lat2, $lng2) {
//      $earth_radius = 6378137;   // Terre = sphère de 6378km de rayon
//      $rlo1 = deg2rad($lng1);
//      $rla1 = deg2rad($lat1);
//      $rlo2 = deg2rad($lng2);
//      $rla2 = deg2rad($lat2);
//      $dlo = ($rlo2 - $rlo1) / 2;
//      $dla = ($rla2 - $rla1) / 2;
//      $a = (sin($dla) * sin($dla)) + cos($rla1) * cos($rla2) * (sin($dlo) * sin(
// $dlo));
//      $d = 2 * atan2(sqrt($a), sqrt(1 - $a));
//      return ($earth_radius * $d);
//    }
//
//    $distance = (round(get_distance_m(0, 0, 0, 0) / 1000,
// 3)). ' km';
// echo $distance;
// return;

//
// $row = $usr->get_all_users_blocked_by_user_connected();
// print_r($row);

// $row = $usr->get_all_details_of_all_id();
//
// //print_r($row);
// $row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();
// // print_r($row_usr_blocked);
// //
// // $turn = 0;
// // foreach ($row_usr_blocked as $i => $value) {
// //   foreach ($row as $key => $value) {
// //     $x = in_array($row_usr_blocked[$i]['id_user_blocked'], $row[0]);
// //     if ($x == true)
// //       echo 'true turn = ' . $turn;
// //     else
// //       echo 'false turn =' . $turn;
// //
// //     $turn++;
// //   }
// // }
// // $i = 0;
//
//
// foreach ($row_usr_blocked as $key => $value) {
//   // code...
//   $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];
//
//   foreach ($row as $key => $value) {
//     if ($row[$key]['id_user'] == $id_user_blocked)
//         {
//           $row[$key] = NULL;
//           array_values($row);
//           break;
//       }
//     }
// }
//
// print_r($row);

//
// function get_distance_m($lat1, $lng1, $lat2, $lng2) {
//      $earth_radius = 6378137;   // Terre = sphère de 6378km de rayon
//      $rlo1 = deg2rad($lng1);
//      $rla1 = deg2rad($lat1);
//      $rlo2 = deg2rad($lng2);
//      $rla2 = deg2rad($lat2);
//      $dlo = ($rlo2 - $rlo1) / 2;
//      $dla = ($rla2 - $rla1) / 2;
//      $a = (sin($dla) * sin($dla)) + cos($rla1) * cos($rla2) * (sin($dlo) * sin($dlo));
//      $d = 2 * atan2(sqrt($a), sqrt(1 - $a));
//      return ($earth_radius * $d);
// }
//
// $x = round(get_distance_m(0,0,5,5) / 1000);
// echo $x;


  //array_values($row)

  $x = $usr->get_if_a_user_like_user_connected(18);
  var_dump($x);
?>
