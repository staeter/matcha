<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] account_signup.php: " . $result);


echo '{
  "result" : "Failure",
  "message" : "signup alert"
}'
// pseudo lastname firstname email password confirm
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/

?>
