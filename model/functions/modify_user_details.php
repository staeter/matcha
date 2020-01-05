<?php
require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';


// ici on set les infos de l utilisateur

function  update_gender($id_user, $datatoinsert)
{
    $query = ('UPDATE user SET gender = :genre WHERE id_user = :id');
    $db->query($query, array(':genre' => $datatoinsert, ':id' => $id_user));
		$row = $db->fetch();
    return $row;
    // on retourne row qui contient toutes les infos contenu dans la table user
}

function update_sexuality_orientation($id_user, $datatoinsert)
{
  $query = ('UPDATE user SET orientation = :orientation WHERE id_user = :id VALUE ');
  $db->query($query, array(':orientation' => $datatoinsert, ':id' => $id_user));
  $row = $db->fetch();
  return $row;
  // on retourne row qui contient toutes les infos contenu dans la table user
}

function update_biography($id_user, $datatoinsert)
{
  $query = ('UPDATE user SET biography = :bio WHERE id_user = :id VALUE ');
  $db->query($query, array(':bio' => $datatoinsert, ':id' => $id_user));
  $row = $db->fetch();
  return $row;
  // on retourne row qui contient toutes les infos contenu dans la table user
}

function set_log($bool)
{
  //tester qu il capte bien la variable = a true or false
  $query = ('UPDATE user SET is_loged = :logged WHERE id_user = :id VALUE ');
  $db->query($query, array(':logged' => $bool, ':id' => $id_user));
  $db->execute();
}

// function set_logout($bool)
// {
//   $query = ('UPDATE user SET is_loged = :logged WHERE id_user = :id VALUE ');
//   $db->query($query, array(':logged' => 'FALSE', ':id' => $id_user));
//   $db->execute();
// }


?>
