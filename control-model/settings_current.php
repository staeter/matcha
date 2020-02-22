<?php
ob_start();
var_dump($_POST);
$result = ob_get_clean();
error_log("[POST] settings_current.php: " . $result);

echo '{
  "data" : {
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "email" : "Doe@gmail.com",
    "gender" : "Woman",
    "orientation" : "Heterosexual",
    "biography" : "Im good",
    "birth" : "1970-01-01",
    "pictures" :
      [ { "id" : 1,
          "path" : "https://images.unsplash.com/photo-1537886079430-486164575c54?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4c747db3353a34b312d05786f47930d3&auto=format&fit=crop&w=600&q=60"
        }
      , { "id" : 2,
          "path" : "https://images.unsplash.com/photo-1537886194634-e6b923f92ff1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9eb2726071e58c1b0a430a75b1047525&auto=format&fit=crop&w=600&q=60"
        }
      , { "id" : 6,
          "path" : "https://images.unsplash.com/photo-1537886243959-0b504cf58aa2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=1171ce40e6e68e663c3399a67a915913&auto=format&fit=crop&w=600&q=60"
        }
      , { "id" : 12,
          "path" : "https://images.unsplash.com/photo-1537886492139-052c27acbfee?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=664282a4bd8b8a69cc860420214df3e7&auto=format&fit=crop&w=600&q=60"
        }
      , { "id" : 43,
          "path" : "https://images.unsplash.com/photo-1537886464786-8a0d500b0da6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=49984d393482456ea5484c3482cc52a9&auto=format&fit=crop&w=600&q=60"
        }
      ],
    "popularity_score" : 100,
    "tags" : ["tag", "lovetags"],
    "geoAuth" : true,
    "latitude" : 12.5,
    "longitude" : 45.32
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "current settings alert"
  }
}';
//
/*
{
  -- mamybe "data" : {
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "email" : "Doe@gmail.com",
    "gender" : "Man" or "Woman",
    "orientation" : "Homosexual" or "Bisexual" or "Heterosexual",
    "biography" : "blablabla",
    "birth" : "some date",
    "pictures" : ["/data/name.png", ...],
    "popularity_score" : 12,
    "tags" : ["#tag", ...]
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/
?>
