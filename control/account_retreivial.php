<?php
  session_start();
	require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
	require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
  $db = new Database($dsn, $username, $password);
try {
		$usr = User::receive_account_retrieval($_POST['a'], $_GET['b'], $db);
	} catch (Exception $e) {
    echo '{
      "result" : "Failure",
      "message" : "'.$e->getMessage().'"
    }';
    }

	if ($_POST['newpw'] != '' && $_POST['confirmpw'] != '' && $_POST['newpw'] == $_POST['confirmpw']) {
		try {
			$usr->set_password(hash_password($_POST['newpw']));
      echo '{
        "result" : "Succes",
        "message" : "Votre mot de passe à été modifié avec succès !"
      }';
		} catch (Exception $e) {
      echo '{
        "result" : "Failure",
        "message" : "'.$e->getMessage().'"
      }';
    }
	}
?>
