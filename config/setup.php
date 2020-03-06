<?php

	require $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';

	// /!\ the present database will be deleted if set to true /!\
	$reset_db = true;


	echo "Connecting to the database...<br>";
	try
	{
		if ($reset_db)
		{
			echo "Reset of the database...<br>";

			$db = new Database($dsn, $username, $password);
			$db->exec("DROP DATABASE IF EXISTS `" . $dbname . "`;");
			$db->exec("CREATE DATABASE IF NOT EXISTS `" . $dbname . "`; USE `" . $dbname . "`;");

			$db = new Database($dsn . ";dbname=" . $dbname, $username, $password);
			$db->exec(file_get_contents($setup_file));
		}
		else
		{
			$db = new Database($dsn . ";dbname=" . $dbname, $username, $password);
		}
	}
	catch(PDOException $e) {
	    echo ('Error while connecting to mysql server: ' . $e . '<br>');
		exit;
	}
	echo "Connection established succesfuly.<br>";
?>
