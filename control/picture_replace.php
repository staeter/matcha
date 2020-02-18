<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$usr = unserialize($_SESSION['user']);

$id_file_to_update = $_POST['id'];

if (is_uploaded_file($_FILES['pictureFile']['tmp_name']))
  move_uploaded_file($_FILES['pictureFile']['tmp_name'], "../Pictures" . '/' . $_FILES['pictureFile']['name']);

$path_fichier = "/Pictures" . '/' . $_FILES['pictureFile']['name'];

// la photo est sauvee sur le serveur mtn e

//  -> remplacer la photo dans la base de donnée
$usr->update_picture($id_file_to_update, $path_fichier);

// -> renvoyer le tableau avec les bonnes valeurs
$rowpic = $usr->get_all_picture();


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
    "color" : "DarkGreen",
    "message" : "Ur files was uploaded"
  }
}';
?>
