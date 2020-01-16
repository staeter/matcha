<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] chat_message.php: " . $result);

echo '{
  "confirm" : false,
  "alert" : {
    "color" : "DarkBlue",
    "message" : "message sent"
  }
}';
// content id
/*
{
  "confirm" : true or false,
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/ //ni: test not working for whatever reason
?>
