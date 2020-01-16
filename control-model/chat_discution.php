<?php
echo '{
  "data" : {
    "messages" : [
      {
        "sent" : "True",
        "date" : "12-01-2020",
        "content" : "blablabla"
      },
      {
        "sent" : "false",
        "date" : "12-01-2020",
        "content" : "hahaha"
      },
      {
        "sent" : "True",
        "date" : "12-01-2020",
        "content" : "hohoho"
      },
      {
        "sent" : "False",
        "date" : "12-01-2020",
        "content" : "hell yeah"
      }
    ]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "chat discution alert"
  }
}'
// id[int]
/*
{
  -- mamybe "data" : {
    "messages" : [
      {
        "sent" : "True" or "False",
        "date" : "some date",
        "content" : "blablabla"
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
?>
