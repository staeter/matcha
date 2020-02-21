<?php


// echo '{
//   "data" : {
//     "pseudo" : "sosa",
//     "picture" : "Pictures/default-profile-picture.jpg"
//   },
//   "alert" : {
//     "color" : "DarkGreen",
//     "message" : "Welcome!"
//   }
// }';

session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';

$x = -1;
try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User($_POST['pseudo'], hash_password($_POST['password']), $db);


  if ($usr->is_validated_account())
      $x = 1;
  else {
    $x = 6;
  }
  if ($x == 1)
  {
    $_SESSION['id'] = $usr->get_id();
    $_SESSION['pseudo'] = $usr->get_pseudo();
    $_SESSION['mail'] = $usr->get_email();
    $_SESSION['user'] = serialize($usr);
    $usr->set_log(true);
  }

} catch (\Exception $e) {

  if ($e->getCode() == 30)
    $x = 2;
  else if ($e->getCode() == 31)
    $x = 3;
  else if ($e->getCode() == 32)
    $x = 4;
  else if ($e->getCode() == 33)
    $x = 5;
}

if ($x == 1){

  echo '{
    "data" : {
      "pseudo" : "sosa",
      "picture" : "Pictures/default-profile-picture.jpg"
    },
    "alert" : {
      "color" : "DarkGreen",
      "message" : "Welcome!"
    }
  }';
    }
else if ($x == 2){
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "Password and user doesnt match"
    }
  }';

}
else if ($x == 3)
{
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "Your pseudo doesnt exist!"
    }
  }';

}
else if ($x == 4)
{
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "Your password is invalid"
    }
  }';


}
else if ($x == 5)
{
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "Connection with DB failed!"
    }
  }';


}
else if ($x == 6)
{
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "U must confirm ur account for login!"
    }
  }';


}

else {
  echo '{
    "data" : {},
    "alert" : {
      "color" : "DarkRed",
      "message" : "Undefined problem occur, pls contact the admin"
    }
  }';

}


// pseudo password
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/

?>
