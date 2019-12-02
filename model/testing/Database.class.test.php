<?php
	require_once 'initialise.tests.php';

	// valid query 1
	$query = 'SELECT email FROM `user` WHERE `pseudo` = :p';
	$db->query($query, array(':p' => 'admin'));
	$f = $db->fetch();
	if (!empty(array_diff(array('email' => 'admin@insto.com'), $f))) {
		echo "Valid query 1 FAILED\n";
	}

	// valid query 2
	$query = 'SELECT email FROM `user` WHERE `pseudo` = :p';
	$db->query($query, array(':p' => 'non existant'));
	$f = $db->fetch();
	if ($f !== false) {
		echo "Valid query 2 FAILED\n";
	}

	// invalid query 1
	$query = 'email FROM `user` WHERE `pseudo` = :p';
	$exception = false;
	try {
		$db->query($query, array(':p' => 'admin'));
	}
	catch (PDOException $e) {
		//echo $e;
		$exception = true;
	}
	if ($exception !== true) {
		echo "Invalid query 1 FAILED\n";
	}

	// invalid query 2
	$query = 'SELECT email FROM `user` WHERE `pseudo` = :p';
	$exception = false;
	try {
		$db->query($query, array(/*':p' => 'admin', */'shity key' => 'shity value'));
	}
	catch (PDOException $e) {
		//echo $e;
		$exception = true;
	}
	if ($exception !== true) {
		echo "Invalid query 2 FAILED\n";
	}
?>
