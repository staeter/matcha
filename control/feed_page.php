<?php
ob_start();
var_dump($_POST);

$result = ob_get_clean();
error_log("[POST] feed_page.php: " . $result);

echo '{
  "data" : {
    "pageAmount" : 1,
    "elemAmount" : 1,
    "users" : [
      {
        "id" : 2,
        "pseudo" : "John",
        "picture" : "/data/doe.png",
        "tags" : ["geek", "foot"],
        "liked" : false
      },
      {
        "id" : 2,
        "pseudo" : "Lise",
        "picture" : "/data/liypick.png",
        "tags" : ["boty", "makup"],
        "liked" : false
      },
      {
        "id" : 2,
        "pseudo" : "Marcel",
        "picture" : "/data/marcel.png",
        "tags" : ["tatoo", "beer"],
        "liked" : false
      },
      {
        "id" : 2,
        "pseudo" : "clara",
        "picture" : "/data/gotaga.png",
        "tags" : ["geek", "fun"],
        "liked" : true
      }
    ]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "feed page call"
  }
}';
// page[int]
/*
{
  -- mamybe "data" : {
    "pageAmount" : 12,
    "elemAmount" : 12,
    "users" : [
      {
        "id" : 12,
        "pseudo" : "myPseudo",
        "picture" : "/data/name.png",
        "tags" : ["#tag", ...],
        "liked" : true or false
      },
      ...
    ]
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
/!\ modifs
*/

?>
