<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] user_like.php: " . $result);

echo '{
  "data" : {
    "newLikeStatus" : true
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "liked status updated"
  }
}';
// id[int]
/*
{
  -- mamybe "data" : {
    "newLikeStatus" : true or false
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
