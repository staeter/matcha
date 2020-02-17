<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] password_retrieval_request.php: " . $result);

echo '{
  "result" : "Success",
  "message" : "email sent"
}'
// email
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
?>
