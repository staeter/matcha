<?php

	require_once $_SERVER["DOCUMENT_ROOT"] . '/config/setup.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/functions/send_mail.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/view/layout/init.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

	try {
		$u = new User("Simon", "simon.taeter@gmail.com", hash_password("password"), $db);

		var_dump(send_mail($u, "my topic", "blablabla"));
		echo "if true, mail sent";
	} catch (Exception $e) {
		echo $e;
	}

?>
