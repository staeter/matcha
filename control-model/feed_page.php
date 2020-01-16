<?php
echo '{
  "data" : [
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
  ],
  "alert" : {
    "color" : "DarkBlue",
    "message" : "feed page call"
  }
}';
// page[int]
/*
{
  -- mamybe "data" : [
    {
      "id" : 12,
      "pseudo" : "myPseudo",
      "picture" : "/data/name.png",
      "tags" : ["#tag", ...],
      "liked" : true or false
    },
    ...
  ],
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

?>
