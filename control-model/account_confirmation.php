<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] account_confirmation.php: " . $result);

echo '{
  "result" : "Success",
  "message" : "This is a message I want the user to see"
}';
// a b
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
