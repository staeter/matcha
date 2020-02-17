<?php
  session_start();

	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';
  $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

  $x = 0;

	try {
		$usr = User::receive_account_verification_request($_GET['a'], $_GET['b'], $db);
    $x = 1;

	} catch (Exception $e) {

    }

    if ($x == 1){
          echo '{
	"result": "Success",
  "message": "Votre compte à bien été validé !",
	"alert": {
		"color": "DarkGrenn",
		"message": "Votre compte à bien été vérfié."
	}
}';
//header('Location: ../index.php ');
        }
    else if ($x == 0){
      echo '{
	"result": "Failure",
  "message": "Un problème est arrivé dans la validation de votre compte !",
	"alert": {
		"color": "DarkRed",
		"message": "Un problème est arrivé dans la validation de votre compte !"
	}
}';
//  header('Location: ../index.php ');
    }
// a b
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see",
}
*/
?>
