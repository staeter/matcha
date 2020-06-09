<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);
$id_file_to_update = $_POST['id'];

$usr->delete_picture($id_file_to_update);

$rowpic = $usr->get_all_picture();
$_SESSION['picture'] = $rowpic[0]['path'];

echo '{
  "data" :  [
  { "id" : '.$rowpic[0]['id_picture'].',
      "path" :"'.$rowpic[0]['path'].'"
    }
  , { "id" : '.$rowpic[1]['id_picture'].',
      "path" :"'.$rowpic[1]['path'].'"
    }
  , { "id" : '.$rowpic[2]['id_picture'].',
      "path" :"'.$rowpic[2]['path'].'"
    }
  , { "id" : '.$rowpic[3]['id_picture'].',
      "path" :"'.$rowpic[3]['path'].'"
    }
  , { "id" : '.$rowpic[4]['id_picture'].',
      "path" :"'.$rowpic[4]['path'].'"
    }
  ],
  "alert" : {
    "color" : "DarkRed",
    "message" : "Ur files was deleted"
  }
}';
