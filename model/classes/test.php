<?php

session_start();
require 'User.class.php';
require '../functions/hash_password.php';

$x = 0;
try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User('Ssss', 'r', 'sosa' ,'aaa@gmail.com', hash_password('password'), $db);
    if ($usr->is_validated_account()) {
  			$x = 1;
  		}
    else {
  			$x = 0;

  		}

} catch (Exception $e) {

  // echo "Le code de l'exception est : " . $e->getCode();


  echo $e->getMessage();
  if ($e->getCode() == 42)
  {
    echo "string";
  }

}



echo '<br>';
echo $x;


?>
