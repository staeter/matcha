<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] account_signin.php: " . $result);


echo '{
  "data" : {
    "pseudo" : "Joney",
    "picture" : "/data/joneysPick.png"
  },
  "alert" : {
    "color" : "DarkGreen",
    "message" : "Welcome!"
  }
}'

// pseudo password
/*
{
  "data" : {
    "pseudo" : "Joney",
    "picture" : "/data/joneysPick.png"
  },
  "alert" : {
    "color" : "DarkGreen",
    "message" : "Welcome!"
  }
}
*/

?>
