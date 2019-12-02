<?php
	try {

		require_once $_SERVER["DOCUMENT_ROOT"] . '/model/testing/initialise.tests.php';
		require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
		require_once $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

		// construct based on id_cookie
		// $u1 = new User(2, $db);
		//echo ($u1->_id) . "\n";
		//echo ($u1->_pseudo) . "\n";
		//echo ($u1->_email) . "\n";

		// construct on loging in
		$u2 = new User("john@mail.com", hash_password("johnpw"), $db);
		//echo ($u2->_id) . "\n";
		//echo ($u2->_pseudo) . "\n";
		//echo ($u2->_email) . "\n";

		// construct on account creation
		$u3 = new User("Jonney", "charlie.bit@my.finger.us", hash_password("LEEEROY_JENKINS!"), $db);
		//echo ($u3->_id) . "\n";
		//echo ($u3->_pseudo) . "\n";
		//echo ($u3->_email) . "\n";

		// set
		$u2->set_pseudo("ClaP");
		$db->query("SELECT pseudo FROM user WHERE email = :em;", array(':em' => $u2->get_email()));
		$row = $db->fetch();
		if ($row['pseudo'] != "ClaP") {
			echo "set_pseudo FAILED: " . $row['pseudo'] . "\n";
		}

		$u2->set_email("press@f.pr");
		$db->query("SELECT email FROM user WHERE pseudo = :ps;", array(':ps' => $u2->get_pseudo()));
		$row = $db->fetch();
		if ($row['email'] != "press@f.pr") {
			echo "set_email FAILED: " . $row['email'] . "\n";
		}

		$u3->set_password(hash_password("LEEEROY_JENKINS!"), hash_password("longcat is looooooooooooooooooonnnnnnnnng!"));
		$db->query("SELECT password FROM user WHERE pseudo = :ps;", array(':ps' => $u3->get_pseudo()));
		$row = $db->fetch();
		if (strcmp($row['password'], hash_password("longcat is looooooooooooooooooonnnnnnnnng!")) != 0) {
			echo "set_password FAILED: " . $row['password'] . "\n";
		}



		// is
		if (!User::is_email_in_use("charlie.bit@my.finger.us", $db)) {
			echo "is_email_in_use FAILED: wrong answere false instead of true\n";
		}
		if (User::is_email_in_use("nonexistant@mail.test", $db)) {
			echo "is_email_in_use FAILED: wrong answere true instead of false\n";
		}
		if (!$u2->is_correct_password(hash_password("johnpw"))) {
			echo "is_correct_password FAILED: wrong answere false instead of true\n";
		}
		if ($u3->is_correct_password(hash_password("LEEEROY_JENKINS!"))) {
			echo "is_correct_password FAILED: wrong answere true instead of false\n";
		}


		// cookie
		require_once "new_id_cookie.test.php";
		$u2->link_cookie($_COOKIE["my_test_id_cookie1"]);
		$db->query("SELECT max(id_cookie) AS id_cookie FROM user JOIN cookie ON cookie.id_user = user.id_user WHERE pseudo = :ps;", array(':ps' => $u2->get_pseudo()));
		$row = $db->fetch();
		if (strcmp($row['id_cookie'], $_COOKIE["my_test_id_cookie1"]) != 0) {
			echo "link_cookie FAILED: " . $row['id_cookie'] . "\n";
		}

	} catch (Exception $e) {
		echo $e;
	}
?>
