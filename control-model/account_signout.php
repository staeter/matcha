<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] account_signout.php: " . $result);


echo '{
  "result" : "Success",
  "message" : "Bye!"
}'
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
