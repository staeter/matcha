<?php
echo '{
  "data" : {
    "chats" : [
      {
        "id" : 5,
        "pseudo" : "Joney",
        "picture" : "/data/joneysPick.png",
        "last_log" : "Now",
        "last_message" : "blabla!",
        "unread" : "True"
      },
      {
        "id" : 12,
        "pseudo" : "Francis",
        "picture" : "/data/franc.png",
        "last_log" : "03-01-2020",
        "last_message" : "wow lol!",
        "unread" : "True"
      },
      {
        "id" : 14,
        "pseudo" : "lisa",
        "picture" : "/data/lizProfile.png",
        "last_log" : "29-12-2020",
        "last_message" : "hey! Lov u bro",
        "unread" : "False"
      }
    ]
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "chat list alert"
  }
}';
//
/*
{
  -- mamybe "data" : {
    "chats" : [
      {
        "id" : 12,
        "pseudo" : "myPseudo",
        "picture" : "/data/name.png",
        "last_log" : "Now" or "some date",
        "last_message" : "blabla!",
        "unread" : "True" or "False"
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
