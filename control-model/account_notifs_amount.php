<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] account_notifs_amount.php: " . $result);


echo '{
  "data" : {
    "amount" : 234
  }
}';
//
/*
{
  -- mamybe "data" : {
    "amount" : 12
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
