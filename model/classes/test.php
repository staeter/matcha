<?php

session_start();
require 'User.class.php';
require '../functions/hash_password.php';

$x = 0;
try {
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  $usr = new User('red', 'r', 'sosa' ,'sos@d.com', hash_password('r'), $db);

  $usr->set_log(true);

  $usr->send_account_verification_request("http://localhost:8080/control/confirm_account.php");
} catch (Exception $e) {

   echo "Le code de l'exception est : " . $e->getCode();


  echo $e->getMessage();
  if ($e->getCode() == 42)
  {
    echo "string";
  }

}



echo '<br>';
echo $x;


?>
