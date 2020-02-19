<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
// ob_start();
// var_dump($_POST);
// return;
// $result = ob_get_clean();
// error_log("[POST] feed_filter.php: " . $result);

///////////////////////////////////////////////
//
// array(8) {
  // ["ageMin"]=>
  // string(2) "16"
  // ["ageMax"]=>
  // string(3) "120"

  $age_min = $_POST['ageMin'];
  $age_max = $_POST['ageMax'];

  // je dois convertir age min & max en valeur AAAA-MM-JJ
  $age_min2 = date();

  // je dois recuperer un tableau trier dont les users ont un age compris
  // entre
  // age min & age max
  $row = $usr->get_all_details_of_all_id_between_age_min_max($age_min, $age_max);




  // ["popularityMin"]=>
  // string(2) "10"
  // ["popularityMax"]=>
  // string(3) "100"
  // ["distanceMax"]=>
  // string(2) "76"
  // ["tags"]=>
  // string(15) "["sosa","reda"]"
  // ["viewed"]=>
  // string(5) "False"
  // ["liked"]=>
  // string(5) "False"

//
//
//
//
//////////////////////////////////////////////

echo '{
  "data" : {
    "pageAmount" : 5,
    "elemAmount" : 18,
    "users" : [
      {
        "id" : 1,
        "pseudo" : "John",
        "picture" : "/data/doe.png",
        "tags" : ["geek", "foot"],
        "liked" : false
      },
      {
        "id" : 3,
        "pseudo" : "Lise",
        "picture" : "/data/liypick.png",
        "tags" : ["boty", "makup"],
        "liked" : false
      },
      {
        "id" : 12,
        "pseudo" : "Marcel",
        "picture" : "/data/marcel.png",
        "tags" : ["tatoo", "beer"],
        "liked" : false
      },
      {
        "id" : 13,
        "pseudo" : "clara",
        "picture" : "/data/gotaga.png",
        "tags" : ["geek", "fun"],
        "liked" : true
      }
    ]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "feed filter call"
  }
}';
// ageMin[int] ageMax[int] distanceMax[int] popularityMin[int] popularityMax[int] tags[json array of strings] viewed[True/False] liked[True/False]
/*
{
  -- mamybe "data" : {
    "pageAmount" : 12,
    "elemAmount" : 12,
    "users" : [ // NB: only fully completed users accounts
      {
        "id" : 12,
        "pseudo" : "myPseudo",
        "picture" : "/data/name.png",
        "tags" : ["tag", ...],
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
*/

// NB: empty users list and alert if account not complete
?>
