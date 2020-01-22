<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] user_like.php: " . $result);

echo '{
  "data" : {
    "id" : 3,
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
    "id" : 12,
    "newLikeStatus" : true or false
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
/!\ changes happened
*/
?>
