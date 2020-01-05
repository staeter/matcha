<?php

session_start();
require 'User.class.php';
require '../functions/hash_password.php';

$x = 0;
try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User('SOSALOCA', 'rrr', 'sosa' ,'emai@gmail.com', hash_password('password'), $db);
    if ($usr->is_validated_account()) {
  			$x = 1;
  		}
    else {
  			$x = 0;

  		}

} catch (\Exception $e) {

  echo $e;
}

echo '<br>';
echo $x;


?>
