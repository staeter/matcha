<?php
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = (unserialize($_SESSION['user']));


$usr->set_a_block($_POST['id']);
$usr->substract_popularity_of_this_user($_POST['id']);
//verifier qu il y ai un conv active si oui supprimer le match + la conversation
$usr->remove_like_2($_SESSION['id']);
$usr->remove_like($_POST['id']);
$usr->delete_conv_between_user($_POST['id']);

echo '{
  "result" : "Success",
  "message" : "user Blocked!"
}';

?>
