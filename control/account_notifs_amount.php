<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$count = $usr->get_count_notif_user_connected();

echo '{
  "data" : {
    "amount" : '.$count.'
  }
}';
?>
