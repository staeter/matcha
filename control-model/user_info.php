<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] user_info.php: " . $result);

echo '{
  "data" : {
    "id" : 1,
    "pseudo" : "hisPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "gender" : "Woman",
    "orientation" : "Homosexual",
    "biography" : "hohoho",
    "birth" : "11-11-2011",
    "last_log" : "Now",
    "pictures" : ["https://images.unsplash.com/photo-1537886079430-486164575c54?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4c747db3353a34b312d05786f47930d3&auto=format&fit=crop&w=600&q=60", "https://images.unsplash.com/photo-1537886194634-e6b923f92ff1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9eb2726071e58c1b0a430a75b1047525&auto=format&fit=crop&w=600&q=60", "https://images.unsplash.com/photo-1537886243959-0b504cf58aa2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=1171ce40e6e68e663c3399a67a915913&auto=format&fit=crop&w=600&q=60", "https://images.unsplash.com/photo-1537886492139-052c27acbfee?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=664282a4bd8b8a69cc860420214df3e7&auto=format&fit=crop&w=600&q=60", "https://images.unsplash.com/photo-1537886464786-8a0d500b0da6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=49984d393482456ea5484c3482cc52a9&auto=format&fit=crop&w=600&q=60" ],
    "popularity_score" : 0,
    "tags" : ["joy", "stuff"],
    "liked" : false
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "usr info received"
  }
}';
// id[int]
/*
{
  -- mamybe "data" : {
    "id" : 12,
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "gender" : "Man" or "Woman",
    "orientation" : "Homosexual" or "Bisexual" or "Heterosexual",
    "biography" : "blablabla",
    "birth" : "some date",
    "last_log" : "Now" or "some date",
    "pictures" : ["/data/name.png", ...],
    "popularity_score" : 12,
    "tags" : ["#tag", ...],
    "liked" : true or false
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
