<?php
	// require_once $_SERVER["DOCUMENT_ROOT"] . '/model/functions/verbose.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';

	$hostname = "127.0.0.1";
	$username = "root";
	$password = "password";
	$dsn = 'mysql:host='.$hostname.';port=3306;charset=utf8';
	$setup_file = $_SERVER["DOCUMENT_ROOT"] . '/config/database.sql';
	$dumb_data_file = $_SERVER["DOCUMENT_ROOT"] . '/model/testing/dumb_data.sql';
	$dbname = 'testdb';
	$id_cookie_name = 'id_cookie';

	$verbose = TRUE;

	$db = new Database($dsn, $username, $password);

	$db->exec("DROP DATABASE IF EXISTS `" . $dbname . "`;");
	$db->exec("CREATE DATABASE IF NOT EXISTS `" . $dbname . "`; USE `" . $dbname . "`;");

	$db = new Database($dsn . ";dbname=" . $dbname, $username, $password);
	$db->exec(file_get_contents($setup_file));
	$db->exec(file_get_contents($dumb_data_file));
?>
