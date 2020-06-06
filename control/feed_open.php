<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row_test = $usr->get_all_details_of_this_id($usr->get_id());

function array_empty($a)
{
    foreach($a as $k => $v)
        if(empty($v))
            return false;
    return true;
}

function return_error($error)
{
  echo
  '{
    "data": {
    "filtersEdgeValues": {
    "ageMin": 16,
    "ageMax": 120,
    "distanceMax": 20000,
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
  "message": "'. $error .'"
  }
  }';
}
if ($row_test['biography'] == NULL)
{
  return_error("Go set some information of ur account and come back to find ur future love ! (like biography)");
}
$row = $usr->get_all_details_of_all_id();
$row_usr_blocked = $usr->get_all_users_blocked_by_user_connected();

$string = '{
  "data" : {
    "filtersEdgeValues" : {
      "ageMin" : 16,
      "ageMax" : 120,
      "distanceMax" : 20000,
      "popularityMin" : 0,
      "popularityMax" : 100
    },
    "pageContent" : {
      "pageAmount" : 1,
      "elemAmount" : 1,
      "users" : [';

// ici j enleve l occurence de l user connecté  //
foreach ($row as $key => $value)
  if ($row[$key]['id_user'] != $_SESSION['id'])
      $arrayxx[$key] = $row[$key];

// ici j enleve les users sans bio
foreach ($arrayxx as $key => $value)
  if ($arrayxx[$key]['biography'] != NULL)
      $arrayso[$key] = $arrayxx[$key];

if (array_empty($row_usr_blocked) == true)
{
  foreach ($row_usr_blocked as $key => $value) 
  {
    $id_user_blocked = $row_usr_blocked[$key]['id_user_blocked'];
    foreach ($arrayso as $key => $value) 
    {
      if (isset($arrayso[$key]['id_user']) && $arrayso[$key]['id_user'] == $id_user_blocked)
        {
          $arrayso[$key] = NULL;
          array_values($row);
          break;
       }
    }
  }
}

$orientation_int = $usr->get_sexuality_orientation();
$gender = $usr->get_gender();

if ($gender['gender'] == 1)//men
  $gender_int = 1;
else
  $gender_int = 0;

if ($orientation_int['orientation'] == 0)
{
  //if bisexual
  foreach ($arrayso as $key => $value)
  {
    if (isset($arrayso[$key]['gender']) &&  ($arrayso[$key]['orientation'] == 0 || ($arrayso[$key]['gender'] != $gender_int) && $arrayso[$key]['orientation'] == 1))
      $arrayto[$key] = $arrayso[$key];
  }
 
  $tab = array_values($arrayto);

  if (array_empty($tab) == false)
  {
    return_error("There is no user who can suggest to you, just make some search for find ur future love!");
    return;
  }

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
    foreach ($rowtag as $key => $value) 
    {
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
  "alert": {
		"color": "DarkGreen",
		"message": "There is a list of users we suggest you "
	}
  }';

  echo $string;
  return;
}

else if ($orientation_int['orientation'] == 1)
{
  //if hetero
  foreach ($arrayso as $key => $value) 
  {
    if (isset($arrayso[$key]['gender']) && $arrayso[$key]['gender'] != $gender_int && ($arrayso[$key]['orientation'] == 1 || $arrayso[$key]['orientation'] == 0))
      $arraytoreturn[$key] = $arrayso[$key];}

    if (isset($arraytoreturn))
      $tab = array_values($arraytoreturn);
    
    if (array_empty($tab) == false)
    {
      return_error("There is no user who can suggest to you, just make some search for find ur future love!");
      return;
    }

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
      foreach ($rowtag as $key => $value)
      {
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
//if homosexual
else if ($orientation_int['orientation'] == 2)
{
  foreach ($arrayso as $key => $value)
  {
    if (isset($arrayso[$key]['gender']) && $arrayso[$key]['gender'] == $gender_int && ($arrayso[$key]['orientation'] == 2 || $arrayso[$key]['orientation'] == 0))
    {
      $arrayto[$key] = $arrayso[$key];
    }
  }
  if (isset($arrayto))
    $tab = array_values($arrayto);
  
  if (array_empty($tab) == false)
  {
    return_error("There is no user who can suggest to you, just make some search for find ur future love!");
    return;
  }

  foreach ($tab as $key => $value)
  {
      $id_user = $tab[$key]['id_user'];
      $pseudo = $tab[$key]['pseudo'];

      $path = $usr->get_picture_profil($tab[$key]['id_user']);
      $liked = $usr->get_if_liked($tab[$key]['id_user']);
      if ($liked == 1)
        $liked = 'true';
      else
        $liked = 'false';

      $rowtag = $usr->get_tag_of_this_id($tab[$key]['id_user']);
      $output =' "tags" : [';
      $x = 0;

      foreach ($rowtag as $key => $value) 
      {
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
  "alert": {
		"color": "DarkGreen",
		"message": "There is a list of users we suggest you "
	}
  }';
  echo $string;
  return;
}
else 
{
  return_error("There is no profil we can suggest u because ur orientation isnt set");
  return;
}