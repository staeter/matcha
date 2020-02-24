<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row_test = $usr->get_all_details_of_this_id($_SESSION['id']);

function array_empty($a)
{
    foreach($a as $k => $v)
        if(empty($v))
            return false;
    return true;
}

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

$row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

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

foreach ($row as $key => $value) {
  if ($row[$key]['id_user'] != $_SESSION['id'])
      $arrayxx[$key] = $row[$key];}

foreach ($arrayxx as $key => $value) {
  if ($arrayxx[$key]['biography'] != NULL)
      $arrayso[$key] = $arrayxx[$key];}
// la j ai trier tout les users sans l user connecté & sans les users qui nont pas de bio

// foreach ($row_usr_blocked as $keyx => $value) {
//     foreach ($arrayso as $key => $value) {
//         if($row_usr_blocked[$keyx]['id_user_blocked'] != $arrayso[$key]['id_user'])
//           $array[$key] = $arrayso[$key];
//     }
// }
if (array_empty($row_usr_blocked) == true)
{
  foreach ($row_usr_blocked as $key => $value) {
    // code...
    $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];

    foreach ($arrayso as $key => $value) {
      if ($arrayso[$key]['id_user'] == $id_user_blocked)
          {
            $arrayso[$key] = NULL;
            array_values($row);
            break;
        }
      }
  }

}
//print_r($row_usr_blocked);

// j enleve mtn les users bloqué
// print_r($arrayso);
// return;
//
// if (array_empty($arrayso) == FALSE)
// {
//     echo'{
// 	"data": {
// 		"filtersEdgeValues": {
// 			"ageMin": 16,
// 			"ageMax": 120,
// 			"distanceMax": 100,
// 			"popularityMin": 0,
// 			"popularityMax": 100
// 		},
// 		"pageContent": {
// 			"pageAmount": 1,
// 			"elemAmount": 1,
// 			"users": []
// 		}
// 	},
// 	"alert": {
// 		"color": "DarkRed",
// 		"message": "There isnt enoff users on our database come back later 2222!"
// 	}
// }';
//     return;
// }
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

  // if (array_empty($arrayso) == FALSE)
  // {
  //     echo'{
  // 	"data": {
  // 		"filtersEdgeValues": {
  // 			"ageMin": 16,
  // 			"ageMax": 120,
  // 			"distanceMax": 100,
  // 			"popularityMin": 0,
  // 			"popularityMax": 100
  // 		},
  // 		"pageContent": {
  // 			"pageAmount": 1,
  // 			"elemAmount": 1,
  // 			"users": []
  // 		}
  // 	},
  // 	"alert": {
  // 		"color": "DarkRed",
  // 		"message": "There isnt enoff users on our database come back later 333 !"
  // 	}
  // }';
  //     return;
  // }

foreach ($arrayso as $key => $value) {
    $array[$key] = $arrayso[$key];
}


if ($orientation_int['orientation'] == 0)
{
///////////////////////////////

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
foreach ($tab as $key => $value)
{
  $id =  $tab[$key]['id_user'];
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


      $tab = array_values($arraytoreturn);

      foreach ($tab as $key => $value) {
        if ($tab[$key] == NULL)
          {
              unset($tab[$key]);
          }
        }
        $tab = array_values($tab);
        // print_r($tab);
        // return;



foreach ($tab as $key => $value)
{
    $id =  $tab[$key]['id_user'];
    $pseudo = $tab[$key]['pseudo'];

    // echo 'sosa';
    // return;

    // echo $id . ', ' . $pseudo . '<br><br>';
    //
    // return;
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
$string .= ']
}
},
"alert" : {
"color" : "DarkGreen",
"message" : "There is a list of users we suggest you !"
}
}';

echo $string;
return;
}

//homosexual
else if ($orientation_int['orientation'] == 2)
{
///////////////////////////////

foreach ($array as $key => $value)
{
  if ($array[$key]['gender'] == $gender_int)
      {
        $arrayto[$key] = $array[$key];
      }
}


$tab = array_values($arrayto);

foreach ($tab as $key => $value) {
  if ($tab[$key] == NULL)
    {
        unset($tab[$key]);

    }
  }
  $tab = array_values($tab);



foreach ($tab as $key => $value)
{
    $id_user = $tab[$key]['id_user'];
    $pseudo = $tab[$key]['pseudo'];

  //  echo $id_user. ', ' . $pseudo . '<br><br>';
    $path = $usr->get_picture_profil($tab[$key]['id_user']);
    $liked = $usr->get_if_liked($tab[$key]['id_user']);
    if ($liked == 1)
      $liked = 'true';
    else
      $liked = 'false';

    $rowtag = $usr->get_tag_of_this_id($tab[$key]['id_user']);
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
      "id" : '.$id_user.',
      "pseudo" : "'.$pseudo.'",
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
//END OF PROGRAMMMMMM






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
