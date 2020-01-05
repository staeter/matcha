<?php
require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';

// j ai besoin de fonction pour recuper les infos
//  genre toutes les infos dans un tableau on s'en charge apres d'afficher celle voulu
// selon les permisssions du gars connecte

function  get_all_details($id_user)
{
    $query = ('SELECT * FROM user WHERE id_user = :id');
    $db->query($query, array(':id' => $id_user));
		$row = $db->fetch();
    return $row;
    // on retourne row qui contient toutes les infos contenu dans la table user
}

?>
