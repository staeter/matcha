<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] settings_current.php: " . $result);

echo '{
  "data" : {
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "email" : "Doe@gmail.com",
    "gender" : "Man",
    "orientation" : "Bisexual",
    "biography" : "Im good",
    "birth" : "01-01-1970",
    "pictures" : ["/data/pic1.png", "/data/pic2.png", "/data/pic3.png"],
    "popularity_score" : 100,
    "tags" : ["#tag", "lovetags"]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "current settings alert"
  }
}';
//
/*
{
  -- mamybe "data" : {
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "email" : "Doe@gmail.com",
    "gender" : "Man" or "Woman",
    "orientation" : "Homosexual" or "Bisexual" or "Heterosexual",
    "biography" : "blablabla",
    "birth" : "some date",
    "pictures" : ["/data/name.png", ...],
    "popularity_score" : 12,
    "tags" : ["#tag", ...]
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
