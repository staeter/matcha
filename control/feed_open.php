<?php
// ob_start();
// var_dump($_POST);
// $result = ob_get_clean();
// error_log("[POST] feed_open.php: " . $result);

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row_test = $usr->get_all_details_of_this_id($_SESSION['id']);
if ($row_test['biography'] == NULL)
{
  echo'{
"data": {
  "filtersEdgeValues": {
    "ageMin": 16,
    "ageMax": 120,
    "distanceMax": 100,
    "popularityMin": 0,
    "popularityMax": 100
  },
  "pageContent": {
    "pageAmount": 1,
    "elemAmount": 1,
    "users": []
  }
},
"alert": {
  "color": "DarkRed",
  "message": "Go set some information of ur account and come back to find ur future love !"
}
}';
  return;
}
$row = $usr->get_all_details_of_all_id();

$string = '{
  "data" : {
    "filtersEdgeValues" : {
      "ageMin" : 16,
      "ageMax" : 120,
      "distanceMax" : 100,
      "popularityMin" : 0,
      "popularityMax" : 100
    },
    "pageContent" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : [';

      // ici j enleve l occurence de l user connecté  //
$arrayxx = array();
foreach ($row as $key => $value) {
  if ($row[$key]['id_user'] != $_SESSION['id'])
      $arrayxx[$key] = $row[$key];}


foreach ($arrayxx as $key => $value) {
  if ($arrayxx[$key]['biography'] != NULL)
      $array[$key] = $arrayxx[$key];}
// la j ai trier tout les users sans l user connecté & sans les users qui nont pas de bio

if (empty($row) || empty($array))
{
    echo'{
	"data": {
		"filtersEdgeValues": {
			"ageMin": 16,
			"ageMax": 120,
			"distanceMax": 100,
			"popularityMin": 0,
			"popularityMax": 100
		},
		"pageContent": {
			"pageAmount": 1,
			"elemAmount": 1,
			"users": []
		}
	},
	"alert": {
		"color": "DarkRed",
		"message": "There isnt enoff users on our database come back later !"
	}
}';
    return;
}
// ici je devrais faire 3 condition de retour de
// message selon l orientation de l $usr


$orientation_int = $usr->get_sexuality_orientation();
// print_r($orientation_int);
// return;
$gender = $usr->get_gender();

if ($gender['gender'] == 1)
  $gender_int = 1;
  //men
else
  $gender_int = 0;
  //women

if ($orientation_int['orientation'] == 0)
{
///////////////////////////////
foreach ($array as $key => $value)
{

    $path = $usr->get_picture_profil($row[$key]['id_user']);
    $liked = $usr->get_if_liked($row[$key]['id_user']);
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

    $rowtag = $usr->get_tag_of_this_id($row[$key]['id_user']);
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
      "id" : '.$row[$key]['id_user'].',
      "pseudo" : "'.$row[$key]['pseudo'].'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}
$string = substr($string, 0, -1);
$string .= ']
}
},
"alert" : {
"color" : "DarkBlue",
"message" : "feed open call"
}
}';
echo $string;
return;
}


// heterosexuel
// du coup je renvoi le sex different
// ensuite je mettrais une tranche d age de 5 ans d ecart
else if ($orientation_int['orientation'] == 1)
{
///////////////////////////////

foreach ($array as $key => $value) {
  if ($array[$key]['gender'] != $gender_int)
      $arraytoreturn[$key] = $array[$key];}



foreach ($arraytoreturn as $key => $value)
{

    $path = $usr->get_picture_profil($row[$key]['id_user']);
    $liked = $usr->get_if_liked($row[$key]['id_user']);
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

    $rowtag = $usr->get_tag_of_this_id($row[$key]['id_user']);
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
      "id" : '.$row[$key]['id_user'].',
      "pseudo" : "'.$row[$key]['pseudo'].'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}
$string = substr($string, 0, -1);
$string .= ']
}
},
"alert" : {
"color" : "DarkGreen",
"message" : "There is a list of users we suggest you, u will find love sooner that you think !"
}
}';
echo $string;
return;
}

//homosexual
else if ($orientation_int['orientation'] == 2)
{
///////////////////////////////

foreach ($array as $key => $value) {
  if ($array[$key]['gender'] == $gender_int)
      $arraytoreturn[$key] = $array[$key];}

foreach ($arraytoreturn as $key => $value)
{

    $path = $usr->get_picture_profil($row[$key]['id_user']);
    $liked = $usr->get_if_liked($row[$key]['id_user']);
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

    $rowtag = $usr->get_tag_of_this_id($row[$key]['id_user']);
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
      "id" : '.$row[$key]['id_user'].',
      "pseudo" : "'.$row[$key]['pseudo'].'",
      "picture" : "'.$path['path'].'",
      '.$output.',
      "liked" : '.$liked.'
    },';
}
$string = substr($string, 0, -1);
$string .= ']
}
},
"alert" : {
"color" : "DarkBlue",
"message" : "feed open call"
}
}';
echo $string;
return;
}
else {
  echo'{
	"data": {
		"filtersEdgeValues": {
			"ageMin": 16,
			"ageMax": 120,
			"distanceMax": 100,
			"popularityMin": 0,
			"popularityMax": 100
		},
		"pageContent": {
			"pageAmount": 1,
			"elemAmount": 1,
			"users": []
		}
	},
	"alert": {
		"color": "DarkRed",
		"message": "There is no profil we can suggest u because ur orientation isnt set"
	}
}';
  return;
}
//
// echo '{
//   "data" : {
//     "filtersEdgeValues" : {
//       "ageMin" : 16,
//       "ageMax" : 120,
//       "distanceMax" : 100,
//       "popularityMin" : 0,
//       "popularityMax" : 100
//     },
//     "pageContent" : {
//       "pageAmount" : 1,
//       "elemAmount" : 1,
//       "users" : [
//         {
//           "id" : '.$row[0]['id_user'].',
//           "pseudo" : "'.$row[0]['pseudo'].'",
//           "picture" : "/Pictures/addpic.png",
//           "tags" : ["geek ", "foot"],
//           "liked" : false
//         },
//         {
//           "id" : '.$row[1]['id_user'].',
//           "pseudo" : "'.$row[1]['pseudo'].'",
//           "picture" : "/Pictures/addpic.png",
//           "tags" : ["boty ", "makup"],
//           "liked" : false
//         },
//         {
//           "id" : '.$row[2]['id_user'].',
//           "pseudo" : "'.$row[2]['pseudo'].'",
//           "picture" : "/Pictures/addpic.png",
//           "tags" : ["tatoo ", "beer"],
//           "liked" : false
//         },
//         {
//           "id" : '.$row[3]['id_user'].',
//           "pseudo" : "'.$row[3]['pseudo'].'",
//           "picture" : "/Pictures/addpic.png",
//           "tags" : ["geek ", "fun"],
//           "liked" : true
//         }
//       ]
//     }
//   },
//   "alert" : {
//     "color" : "DarkBlue",
//     "message" : "feed open call"
//   }
// }';
//
/*
{
  -- mamybe "data" : {
    "filtersEdgeValues" : {
      "ageMin" : 12,
      "ageMax" : 12,
      "distanceMax" : 12,
      "popularityMin" : 12,
      "popularityMax" : 12
    },
    "pageContent" : {
      "pageAmount" : 12,
      "elemAmount" : 12,
      "users" : [ // NB: only fully completed users accounts
        {
          "id" : 12,
          "pseudo" : "myPseudo",
          "picture" : "/data/name.png",
          "tags" : ["#tag", ...],
          "liked" : true or false
        },
        ...
      ]
    }
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

//ni: form not working for some reason
?>
