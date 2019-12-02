<?php

	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';


	function send_mail()
	{
		$a = func_get_args();
		$i = func_num_args();
		if (function_exists($f = 'send_mail' . $i)) {
			return call_user_func_array($f,$a);
		}
		else {
			throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Wrong amount of parameters ($i).", 0);
		}
	}

	function send_mail3($usr, $subject , $message) {
		if (!User::is_valid($usr)) {
			throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Invalid user.", 1);
		}

		return mail($usr->get_email(), $subject , wordwrap($message,70), "From: mydumbwebsite@insto.com");
	}

	function send_mail4($id_user, $db, $subject , $message) {
		if (!User::is_valid_id($id_user)) {
			throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Invalid user id object.", 1);
		}
		if (!Database::is_valid($db)) {
			throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Invalid db object.", 2);
		}

		$query = 'SELECT email FROM user WHERE id_user = :id;';
		$db->query($query, array(':id' => $id_user));
		$row = $db->fetch();
		if ($row === false) {
			throw new DatabaseException("Fail running" . __FUNCTION__ . ". `id_user` not found in database.", 41);
		}

		return mail($row['email'], $subject , wordwrap($message,70), "From: mydumbwebsite@insto.com");
	}

?>
