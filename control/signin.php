<?php
session_start();
require '../model/classes/User.class.php';
require '../model/functions/hash_password.php';

try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User($_POST['pseudo'], hash_password($_POST['password']), $db);
  $x = 1;

} catch (\Exception $e) {
  	$x = 0;

}


if ($x == 1){
echo '{
  "result" : "Success",
  "message" : "Welcome!"
}';

}
else if ($x == 2){
echo '{
  "result" : "Failure",
  "message" : "Pseudo is not valid !"
}';

}
else {
  echo '{
    "result" : "Failure",
    "message" : "Password or Pseudo doesnt match in our Database !"
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
