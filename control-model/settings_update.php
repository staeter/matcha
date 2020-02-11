<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] settings_update.php: " . $result);


echo '{
  "result" : "Success",
  "message" : "settings update success!"
}'
//pseudo first_name last_name email gender orientation biography birth tags
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
