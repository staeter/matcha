<?php



session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = (unserialize($_SESSION['user']));
if ($usr->is_valid_id($_POST['id']) === false)
{
  echo '{
    "result" : "failure",
    "message" : "the id requested doesnt exist",
    "data" : {
      "newLikeStatus" : false
    },
    "alert" : {
      "color" : "DarkRed",
      "message" : "The id requested doesnt exist"
    }
  }';
  return;
}
else {

  // je dois verifier que l id existe encore en principe oui A FAIRE
  // je dois ajouter un like dans la table like avec l id dees deux users C FAIT


// fonction retour si id qu on veux liker existe (en principe oui mais bon)


// donc gerer cet id n existe plus (car id en dessous de 0 deja reglé)
// gerer une sortie de message adapté a nouveau like/ modif like + / modif like - C FAIT


 if ($usr->is_id_exist($_POST['id']) == FALSE)
 {
   echo '{
   "result" : "Failure",
   "message" : "The id doesnt exist",
   "data" : {
     "newLikeStatus" : false
   },
   "alert" : {
     "color" : "DarkRed",
     "message" : "the id doesnt exist!"
   }
 }';
 return;

 }

$ret = $usr->set_a_like($_POST['id']);
if ($ret == 1)
{
  $usr->set_a_notif_for_like($_POST['id'], ' unliked u  :( )!');
  echo '{
  "data" : {
    "id" : "'.$_POST['id'].'",
    "newLikeStatus" : false,

  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "Like preference updated, u now unlike this user!"
  }
}';
return;

}
if ($ret == 2)
{
    $usr->set_a_notif_for_like($_POST['id'], ' liked u again :p !');
    echo '{
    "data" : {
      "id" : "'.$_POST['id'].'",
      "newLikeStatus" : true
    },
    "alert" : {
      "color" : "DarkBlue",
      "message" : "Like preference updated, u now like this user!"
    }
  }';
  return;
}
if ($ret == 3)
{
  $usr->set_a_notif_for_like($_POST['id'], ' liked u !');
  echo '{
  "data" : {
    "id" : "'.$_POST['id'].'",
    "newLikeStatus" : true
  },
  "alert" : {
    "color" : "DarkBlue",
    "message" : "U liked an User !"
  }
}';
return;

}
}
//id[int]
/*
{
  -- mamybe "data" : {
    "newLikeStatus" : true or false
  },
  -- mamybe "alert" : {
    "color" : "DarkRed",
    "message" : "message for the user"
  }
}
*/

?>
