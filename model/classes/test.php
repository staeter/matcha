<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';


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
$usr = unserialize($_SESSION['user']);
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

//$usr->set_picture();
echo '<br>salut<br>';echo '<br>salut<br>';

echo '<br><br>';
$id_pic = 1;

$row = $usr->get_picture_profil($id_pic);
print_r($row);

echo '<br>salut<br>';
echo $row;
return;
?>
