<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] user_block.php: " . $result);


echo '{
  "result" : "Success",
  "message" : "user blocked!"
}'
// id
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
