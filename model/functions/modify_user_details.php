<?php
require_once $_SERVER["DOCUMENT_ROOT"] . '/Matcha/model/classes/Database.class.php';


// ici on set les infos de l utilisateur

function  update_gender($id_user, $datatoinsert)
{
    $query = ('UPDATE user SET  WHERE id_user = :id VALUE ');
    $db->query($query, array(':id' => $id_user));
		$row = $db->fetch();
    return $row;
    // on retourne row qui contient toutes les infos contenu dans la table user
}



?>
