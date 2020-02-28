<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row = $usr->get_all_details();

if (empty($_POST['pseudo']) || empty($_POST['email']) || empty($_POST['last_name']) || empty($_POST['first_name']))
{
  echo '{
    "result" : "Failure",
    "message" : "Empty value isnt possible dude"
  }';
  return;
}
if ((!empty($_POST['pseudo']) && $_POST['pseudo'] != $_SESSION['pseudo']))
{
    if ($usr->is_valid_pseudo($_POST['pseudo']) == TRUE)
    {
      $usr->set_pseudo($_POST['pseudo']);
      $_SESSION['pseudo'] = $_POST['pseudo'];
    }
    else {
      echo '{
        "result" : "Failure",
        "message" : "Pseudo is Invalid!"
      }';
      return;
    }
}

// UPDATING FIRST NAME

if ((!empty($_POST['first_name']) && ($_POST['first_name'] != $row['firstname'])))
{
    if ($usr->is_valid_pseudo($_POST['first_name']))
      $usr->set_first_name($_POST['first_name']);
    else {
      echo '{
        "result" : "Failure",
        "message" : "First name is Invalid!"
      }';
      return;
    }
}

if ((!empty($_POST['last_name']) && ($_POST['last_name'] != $row['lastname'])))
{
    if ($usr->is_valid_pseudo($_POST['last_name']))
      $usr->set_last_name($_POST['last_name']);
    else {
      echo '{
        "result" : "Failure",
        "message" : "Last name is Invalid!"
      }';
      return;
    }
}

//birth

if (!empty($_POST['birth']))
{
  $usr->set_birthdate($_POST['birth']);
}


// session
if ((!empty($_POST['email'])) && ($_POST['email'] != $row['email']))
{
  if ($usr->is_valid_email($_POST['email']) == FALSE)
  {
    echo '{
      "result" : "Failure",
      "message" : "Le mail n est pas valide"
    }';
    return;
  }

  if ($usr->set_email($_POST['email']) == TRUE)
  {
    $_SESSION['mail'] = $_POST['email'];
  }
  else {
    echo '{
      "result" : "Failure",
      "message" : "Le mail choisi est déjà utiliser"
    }';
    return;
  }
}
if (!empty($_POST['gender']))
{

  // 0 is for women
  // 1 for men

  if ($_POST['gender'] == 'man')
    $gender = 1;
  else {
    $gender = 0;
  }
  $usr->set_gender($gender);
}

if (!empty($_POST['orientation']))
{
  // 0 = bisexual
  // 1 = Heterosexual
  // 2 = Homosexual
  if ($_POST['orientation'] == 'heterosexual')
  {
    $orientatation = 1;
  }
  else if ($_POST['orientation'] == 'homosexual')
  {
    $orientatation = 2;
  }
  else
  {
    $orientatation = 0;
  }
  $usr->set_sexuality_orientation($orientatation);
}

if (!empty($_POST['biography']))
{
  $string = $_POST['biography'];
  $string = str_replace("\n", " ", $string);

  $usr->set_biography($string);
}
//
// if (!(is_empty($_POST['birth'])))
// {
//   $usr->set_birthdate($POST['birth']);
// }
//
//


/// GESTION DES TAGS ici

if (!empty($_POST['tags']))
{
  // je recois ici une string que je dois split avec espace
  $i = 0;
  $string = $_POST['tags'];

  $string = trim($string);
  $array = explode(" ", $string);
  $usr->delete_all_tag();

  foreach ($array as $key => $value) {
    if ($array[$key] != '')
    {
      $tagstocheckifexist .= $array[$key] . ' ';
      $x =  $usr->get_if_tag_already_set($array[$key]);
      if ($x["COUNT(*)"] == '0')
      {
        $usr->set_tag($array[$key]);
      }
    }
  }
  // ic je supprime les entres qui existe mais qui ne sont pas dans l array
  //

}


// ["geoAuth"]=> string(4) "true"
//["latitude"]=> string(9) "4.3172423"
//["longitude"]=> string(10) "50.8882641"

if (!empty($_POST['geoAuth']))
{
  // dans les deux cas je met a jour les trois info dans la bdd
  // pref loc // longitude // latitude
  if ($_POST['geoAuth'] == 'true')
    $accord_loc = 1;
  else
    $accord_loc = 0;

  $usr->set_location($accord_loc, $_POST['longitude'], $_POST['latitude']);
}


echo '{
  "result" : "Success",
  "message" : "settings update success!"
}';

?>
