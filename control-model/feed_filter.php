<?php
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
        "liked" : "False"
      },
      {
        "id" : 3,
        "pseudo" : "Lise",
        "picture" : "/data/liypick.png",
        "tags" : ["boty", "makup"],
        "liked" : "False"
      },
      {
        "id" : 12,
        "pseudo" : "Marcel",
        "picture" : "/data/marcel.png",
        "tags" : ["tatoo", "beer"],
        "liked" : "False"
      },
      {
        "id" : 13,
        "pseudo" : "clara",
        "picture" : "/data/gotaga.png",
        "tags" : ["geek", "fun"],
        "liked" : "True"
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
        "liked" : "True" or "False"
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
