<?php
	// require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/InvalidParamException.class.php';
	// require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/DatabaseException.class.php';
	// require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/CookieException.class.php';
	//
	// // create a cookie wich values is an cookie.id_cookie extracted from the database
	// function new_id_cookie($db, $cookie_name, $domain = "", $expires = 2592000, $path = "/", $secure = FALSE) {
	// 	if (!Database::is_valid($db)) {
	// 		throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Invalid db object.\n", 1);
	// 	}
	//
	// 	$query = 'INSERT INTO cookie () VALUES ();';
	// 	$db->exec($query);
	// 	$query = 'SELECT LAST_INSERT_ID() AS `id_cookie`;';
	// 	$db->query($query, array());
	// 	$row = $db->fetch();
	// 	if ($row === false) {
	// 		throw new DatabaseException("Failed running " . __FUNCTION__ . ". id_cookie not pulled from db.\n");
	// 	}
	//
	// 	// setcookie and error management
	// 	if (!setcookie($cookie_name, $row['id_cookie'], $expires + time(), $path, $domain, $secure)) {
	// 		$query = 'DELETE FROM cookie WHERE id_cookie = :id;';
	// 		$db->query($query, array(':id' => $row['id_cookie']));
	// 		$modified_row_count = $db->rowCount();
	// 		if ($modified_row_count !== 1) {
	// 			throw new DatabaseException("Failed deleting cookie from db after failing to create it on the client side. ". $modified_row_count . " rows have been modified in the database on delete command.\n");
	// 		}
	//
	// 		throw new CookieException("Failed running " . __FUNCTION__ . ". setcookie() failed. The corresponding cookie row in database has been successfully deleted\n");
	// 	}
	// 	$_COOKIE[$cookie_name] = $row['id_cookie'];
	// } //ni: encript id to avoid peoples loging in with other accounts simply by changing their id_cookie
	//
	// function unlink_cookie($db, $id_cookie) {
	// 	if (!Database::is_valid($db)) {
	// 		throw new InvalidParamException("Failed running " . __FUNCTION__ . ". Invalid db object.\n", 1);
	// 	}
	//
	// 	$query = 'UPDATE cookie SET id_user = :idu WHERE id_cookie = :idc;';
	// 	$db->query($query, array(':idu' => null,':idc' => $id_cookie));
	// 	$modified_row_count = $db->rowCount();
	// 	if ($modified_row_count !== 1) {
	// 		throw new DatabaseException("Failed unlinking cookie. ". $modified_row_count . " rows have been modified in the database on update command.\n");
	// 	}
	// }
?>
