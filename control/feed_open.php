<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] feed_open.php: " . $result);

session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$row = $usr->get_all_details_of_all_id();




echo '{
  "data" : {
    "filtersEdgeValues" : {
      "ageMin" : 16,
      "ageMax" : 120,
      "distanceMax" : 100,
      "popularityMin" : 0,
      "popularityMax" : 100
    },
    "pageContent" : {
      "pageAmount" : 5,
      "elemAmount" : 18,
      "users" : [
        {
          "id" : '.$row[0]['id_user'].',
          "pseudo" : "'.$row[0]['pseudo'].'",
          "picture" : "/Pictures/addpic.png",
          "tags" : ["geek ", "foot"],
          "liked" : false
        },
        {
          "id" : '.$row[1]['id_user'].',
          "pseudo" : "'.$row[1]['pseudo'].'",
          "picture" : "/Pictures/addpic.png",
          "tags" : ["boty ", "makup"],
          "liked" : false
        },
        {
          "id" : '.$row[2]['id_user'].',
          "pseudo" : "'.$row[2]['pseudo'].'",
          "picture" : "/Pictures/addpic.png",
          "tags" : ["tatoo ", "beer"],
          "liked" : false
        },
        {
          "id" : '.$row[3]['id_user'].',
          "pseudo" : "'.$row[3]['pseudo'].'",
          "picture" : "/Pictures/addpic.png",
          "tags" : ["geek ", "fun"],
          "liked" : true
        }
      ]
    }
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "feed open call"
  }
}';
//
/*
{
  -- mamybe "data" : {
    "filtersEdgeValues" : {
      "ageMin" : 12,
      "ageMax" : 12,
      "distanceMax" : 12,
      "popularityMin" : 12,
      "popularityMax" : 12
    },
    "pageContent" : {
      "pageAmount" : 12,
      "elemAmount" : 12,
      "users" : [ // NB: only fully completed users accounts
        {
          "id" : 12,
          "pseudo" : "myPseudo",
          "picture" : "/data/name.png",
          "tags" : ["#tag", ...],
          "liked" : true or false
        },
        ...
      ]
    }
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

//ni: form not working for some reason
?>
