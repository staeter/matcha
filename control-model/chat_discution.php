<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] chat_discution.php: " . $result);

echo '{
  "data" : {
    "messages" : [
      {
        "sent" : true,
        "date" : "12-01-2020",
        "content" : "blablabla"
      },
      {
        "sent" : false,
        "date" : "12-01-2020",
        "content" : "hahaha"
      },
      {
        "sent" : true,
        "date" : "12-01-2020",
        "content" : "hohoho"
      },
      {
        "sent" : false,
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
        "sent" : true or false,
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
