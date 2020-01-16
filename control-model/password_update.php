<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] password_update.php: " . $result);

echo '{
  "result" : "Success",
  "message" : "pw updated"
}'
//oldpw newpw confirm
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
?>
