<?php

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';

//**I unserialize my object stored in session and call a method for get the count of notifs */

$usr = unserialize($_SESSION['user']);
$count = $usr->get_count_notif_user_connected();

echo 
  '{
    "data" : 
    {
      "amount" : '.$count.'
    }
  }';