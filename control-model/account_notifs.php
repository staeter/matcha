<?php
echo '{
  "data" : [
    {
      "id" : 12,
      "content" : "somebody did something v1",
      "date" : "01-01-2020",
      "unread" : true
    },
    {
      "id" : 13,
      "content" : "somebody did something v4",
      "date" : "12-08-2017",
      "unread" : true
    },
    {
      "id" : 20,
      "content" : "somebody did something v14",
      "date" : "12-05-2016",
      "unread" : false
    },
    {
      "id" : 1,
      "content" : "somebody did something v23",
      "date" : "12-05-2013",
      "unread" : false
    }
  ],
  "alert" : {
    "color" : "DarkBlue",
    "message" : "account notifs alert"
  }
}';
//
/*
{
  -- mamybe "data" : [
    {
      "id" : 12,
      "content" : "somebody did something",
      "date" : "some date",
      "unread" : true or false
    },
    ...
  ],
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

//ni: other notifs than message received?
?>
