<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] feed_open.php: " . $result);

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
          "id" : 1,
          "pseudo" : "John",
          "picture" : "https://images.unsplash.com/photo-1537886079430-486164575c54?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4c747db3353a34b312d05786f47930d3&auto=format&fit=crop&w=600&q=60",
          "tags" : ["geek", "foot"],
          "liked" : false
        },
        {
          "id" : 3,
          "pseudo" : "Lise",
          "picture" : "https://images.unsplash.com/photo-1537886194634-e6b923f92ff1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9eb2726071e58c1b0a430a75b1047525&auto=format&fit=crop&w=600&q=60",
          "tags" : ["boty", "makup"],
          "liked" : false
        },
        {
          "id" : 12,
          "pseudo" : "Marcel",
          "picture" : "https://images.unsplash.com/photo-1537886243959-0b504cf58aa2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=1171ce40e6e68e663c3399a67a915913&auto=format&fit=crop&w=600&q=60",
          "tags" : ["tatoo", "beer"],
          "liked" : false
        },
        {
          "id" : 12,
          "pseudo" : "Marcel",
          "picture" : "https://images.unsplash.com/photo-1537886492139-052c27acbfee?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=664282a4bd8b8a69cc860420214df3e7&auto=format&fit=crop&w=600&q=60",
          "tags" : ["tatoo", "beer"],
          "liked" : false
        },
        {
          "id" : 13,
          "pseudo" : "clara",
          "picture" : "https://images.unsplash.com/photo-1537886464786-8a0d500b0da6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=49984d393482456ea5484c3482cc52a9&auto=format&fit=crop&w=600&q=60",
          "tags" : ["geek", "fun"],
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
