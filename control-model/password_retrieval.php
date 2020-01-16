<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] password_retrieval.php: " . $result);

echo '{
  "result" : "Success",
  "message" : "password retrieval success!"
}'
// a b newpw confirm
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/
?>
