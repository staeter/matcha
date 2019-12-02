<?php
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/InvalidParamException.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/DatabaseException.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/functions/send_mail.php';

	class User {
		private $_id;
		private $_pseudo;
		private $_email;
		private $_db;

		/*
		** -------------------- Serialize --------------------
		*/
		public function serialize()
	    {
	        return serialize([
	            $this->_id,
	            $this->_pseudo,
	            $this->_email,
				$this->_db
	        ]);
	    }

	    public function unserialize($data)
	    {
	        list(
	            $this->_id,
	            $this->_pseudo,
	            $this->_email,
				$this->_db
	        ) = unserialize($data);
	    }


		/*
		** -------------------- Construct --------------------
		*/
		public function __construct()
		{
			$a = func_get_args();
	        $i = func_num_args();
	        if (method_exists($this, $f = '__construct' . $i)) {
	            call_user_func_array(array($this,$f),$a);
	        }
			else {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Wrong amount of parameters ($i).", 0);
			}
		}

		private function __construct2($id_user, $db)
		{
			// test parameters validity
			if (!User::is_valid_id($id_user)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid id.", 21);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid db object.", 22);
			}

			// query from database
			$query = "SELECT pseudo, email FROM user WHERE id_user = :idu;";
			$db->query($query, array(':idu' => $id_user));
			$row = $db->fetch();
			if ($row === false) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". id_user not found in database.", 30);
			}

			// set object properties
			$this->_id = $id_user;
			$this->_pseudo = $row['pseudo'];
			$this->_email = $row['email'];
			$this->_db = $db;
		}

		private function __construct3($pseudo, $hashed_password, $db)
		{
			// test parameters validity
			if (!User::is_valid_pseudo($pseudo)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid pseudo.", 31);
			}
			if (!User::is_valid_hashed_password($hashed_password)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid hashed password.", 32);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid db object.", 33);
			}

			// query from database
			$query = 'SELECT id_user, email FROM user WHERE pseudo = :ps AND password = :pw;';
			$db->query($query, array(':ps' => $pseudo, ':pw' => $hashed_password));
			$row = $db->fetch();
			if ($row === false) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Pseudo-password combination not found in database.", 30);
			}

			// set object properties
			$this->_id = $row['id_user'];
			$this->_pseudo = $pseudo;
			$this->_email = $row['email'];
			$this->_db = $db;
		}

		private function __construct4($pseudo, $email, $hashed_password, $db)
		{
			// test parameters validity
			if (!User::is_valid_pseudo($pseudo)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid pseudo.", 41);
			}
			if (!User::is_valid_email($email)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid email.", 42);
			}
			if (!User::is_valid_hashed_password($hashed_password)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid password.", 43);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid db object.", 44);
			}
			if (User::is_email_in_use($email, $db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Email in use.", 42);
			}

			// adding new user to database and pull the id_user
			$query = 'INSERT INTO user (pseudo, email, password) VALUES (:ps, :em, :pw);';
			$db->query($query, array(':ps' => $pseudo, ':em' => $email, ':pw' => $hashed_password));
			$query = 'SELECT LAST_INSERT_ID() AS `id_user`;';
			$db->query($query, array());
			$row = $db->fetch();
			if ($row === false) {
				throw new DatabaseException("Failed constructing " . __CLASS__ . ". Id not pulled from db.");
			}

			// set object properties
			$this->_id = $row['id_user'];
			$this->_pseudo = $pseudo;
			$this->_email = $email;
			$this->_db = $db;
		}


		/*
		** -------------------- Magic methods --------------------
		*/
		public function __destruct() {
			$this->_id = null;
			$this->_pseudo = null;
			$this->_email = null;
			$this->_db = null;
		}
		public function __toString()
		{
			return get_pseudo();
		}


		/*
		** -------------------- Account verification --------------------
		*/
		public function send_account_verification_request($server_url)
		{
			$query = 'INSERT INTO account_verification (account_verification_key, id_user) VALUES ((SELECT FLOOR(RAND()*1000000000000000) AS random_key), :idu);';
			$this->_db->query($query, array(':idu' => $this->_id));
			$query = 'SELECT account_verification_key FROM account_verification WHERE id_user = :idu;';
			$this->_db->query($query, array(':idu' => $this->_id));
			$row = $this->_db->fetch();
			if ($row === false) {
				throw new DatabaseException("Failed constructing " . __CLASS__ . ". Id not pulled from db.");
			}

			send_mail(
				$this,
				"INSTO: account confirmation link.",
				$server_url . '?a=' . $this->get_id() . '&b=' . $row['account_verification_key']
			);
		}
		public static function receive_account_verification_request($a, $b, $db)
		{
			if (!User::is_valid_id($a)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid a param.", 1);
			}
			if (!preg_match("/^[1-9][0-9]*$/", $b)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid b param.", 2);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid db object.", 3);
			}

			// delete account_verification entry from database
			$query = 'DELETE FROM account_verification WHERE account_verification_key = :key AND id_user = :idu;';
			$db->query($query, array(':idu' => $a, ':key' => $b));
			$modified_row_count = $db->rowCount();
			if ($modified_row_count !== 1) {
				throw new InvalidParamException("Account verification failed. a-b combination not found in database.");
			}

			// return the user to log him in
			return new User($a, $db);
		}
		public function is_validated_account()
		{
			$query = 'SELECT account_verification_key FROM account_verification WHERE id_user = :idu;';
			$this->_db->query($query, array(':idu' => $this->get_id()));
			$row = $this->_db->fetch();
			if ($row === false) {
				// if no row dedicated to this user in account_verification_key
				return true;
			}
			// if there is
			return false;
		}


		/*
		** -------------------- Account retrieval --------------------
		*/
		public static function send_account_retrieval($email, $db, $server_url)
		{
			if (!User::is_valid_email($email)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid email.", 1);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid db object.", 2);
			}

			// query from database to make sure the email is linked with a user
			$query = "SELECT id_user FROM user WHERE email = :m;";
			$db->query($query, array(':m' => $email));
			$row = $db->fetch();
			if ($row === false) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Email not found in database.", 1);
			}

			$id_user = $row['id_user'];

			// query to remove the other account_retrieval_requests sent by this user
			$query = 'DELETE FROM account_retrieval_requests WHERE id_user = :idu;';
			$db->query($query, array(':idu' => $id_user));

			// query to add an account_retrieval_request to the db
			$query = 'INSERT INTO account_retrieval_requests (account_retrieval_request_key, id_user) VALUES ((SELECT FLOOR(RAND()*1000000000000000) AS random_key), :idu);';
			$db->query($query, array(':idu' => $id_user));

			// query to retrieve the account_retrieval_request_key
			$query = 'SELECT account_retrieval_request_key FROM account_retrieval_requests WHERE id_user = :idu;';
			$db->query($query, array(':idu' => $id_user));
			$row = $db->fetch();
			if ($row === false) {
				throw new DatabaseException("Failed running " . __METHOD__ . ". Key not pulled from db.");
			}

			$account_retrieval_request_key = $row['account_retrieval_request_key'];

			send_mail(
				$id_user,
				$db,
				"INSTO: account retrieval link.",
				$server_url . '?a=' . $id_user . '&b=' . $account_retrieval_request_key
			);
		}
		public static function receive_account_retrieval($a, $b, $db)
		{
			if (!User::is_valid_id($a)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid a param.", 1);
			}
			if (!preg_match("/^[1-9][0-9]*$/", $b)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid b param.", 2);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid db object.", 3);
			}

			// delete account_verification entry from database
			$query = 'DELETE FROM account_retrieval_requests WHERE account_retrieval_request_key = :key AND id_user = :idu;';
			$db->query($query, array(':idu' => $a, ':key' => $b));
			$modified_row_count = $db->rowCount();
			if ($modified_row_count !== 1) {
				throw new InvalidParamException("Account retieval failed. a-b combination not found in database.");
			}

			// return the user to log him in
			return new User($a, $db);
		}


		/*
		** -------------------- Set --------------------
		*/
		public function set_pseudo($new)
		{
			if (!User::is_valid_pseudo($new)) {
				throw new InvalidParamException("Failed setting pseudo. Invalid pseudo.");
			}

			$query = 'UPDATE user SET pseudo = :ps WHERE id_user = :id;';
			$this->_db->query($query, array(':ps' => $new, ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting pseudo. " . $modified_row_count . " rows have been modified in the database.");
			}

			$this->_pseudo = $new;
		}
		public function set_email($new)
		{
			if (!User::is_valid_email($new)) {
				throw new InvalidParamException("Fail setting email. Invalid email.", 1);
			}
			if (User::is_email_in_use($new, $this->_db)) {
				throw new InvalidParamException("Failed setting email. Email in use.", 1);
			}

			$query = 'UPDATE user SET email = :em WHERE id_user = :id;';
			$this->_db->query($query, array(':em' => $new, ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting email. " . $modified_row_count . " rows have been modified in the database.");
			}

			$this->_email = $new;
		}
		public function set_password($hashed_new)
		{
			if (!User::is_valid_hashed_password($hashed_new)) {
				throw new InvalidParamException("Fail setting password. Invalid new password.", 2);
			}

			// update db
			$query = 'UPDATE user SET password = :pw WHERE id_user = :id;';
			$this->_db->query($query, array(':pw' => $hashed_new, ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting password. " . $modified_row_count . " rows have been modified in the database.");
			}
		}
		public function set_pref_mail_notifications()
		{
			// update db
			$query = 'UPDATE user SET pref_mail_notifications = :pmn WHERE id_user = :id;';
			$this->_db->query($query, array(':pmn' => $this->get_pref_mail_notifications() ? '0' : '1', ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting pref_mail_notifications. " . $modified_row_count . " rows have been modified in the database.");
			}
		}

		/*
		** -------------------- Get --------------------
		*/
		public function get_id()
		{
			return $this->_id;
		}
		public function get_pseudo()
		{
			return $this->_pseudo;
		}
		public function get_email()
		{
			return $this->_email;
		}
		public function get_pref_mail_notifications()
		{
			// query from database
			$query = 'SELECT pref_mail_notifications FROM user WHERE id_user = :id;';
			$this->_db->query($query, array(':id' => $this->get_id()));
			$row = $this->_db->fetch();
			if ($row === false) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Id not found in database.");
			}

			//echo 'get_pref_mail_notifications: "' . (($row['pref_mail_notifications'] == '1' ? true : false) ? 't'  . '"' : 'f' . '"');
			return $row['pref_mail_notifications'] == '1' ? true : false;
		}

		/*
		** -------------------- Is valid --------------------
		*/
		public static function is_valid_email($email)
		{
			$patern = "/\A(?=[a-z0-9@.!#$%&'*+\/=?^_`{|}~-]{6,254}\z)(?=[a-z0-9.!#$%&'*+\/=?^_`{|}~-]{1,64}@)[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/";
			return preg_match($patern, $email) ? TRUE : FALSE;
		}
		public static function is_valid_pseudo($pseudo)
		{
			$patern = "/^[a-zA-Z0-9]{3,64}$/";
			return preg_match($patern, $pseudo) ? TRUE : FALSE;
		}
		public static function is_valid_password($password)
		{
			$patern = "/^.{12,64}$/";
			return preg_match($patern, $password) ? TRUE : FALSE;
		}
		public static function is_valid_hashed_password($password)
		{
			$patern = "/^[a-f0-9]{128}$/"; // related to hash_password()
			return preg_match($patern, $password) ? TRUE : FALSE;
		}
		public static function is_valid_id($id)
		{
			if (gettype($id) === 'integer' && $id > 0) {
				return TRUE;
			}
			if (gettype($id) === 'string' && preg_match("/^[1-9][0-9]*$/", $id)) {
				return TRUE;
			}
			return FALSE;
		}
		public static function is_email_in_use($email, $db)
		{
			if (!User::is_valid_email($email)) {
				return FALSE;
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid db object.", 2);
			}

			$query = 'SELECT id_user FROM user WHERE email = :em;';
			$db->query($query, array(':em' => $email));
			$row = $db->fetch();
			if ($row !== false) {
				return TRUE;
			}
			return FALSE;
		}
		public function is_correct_password($hashed_password)
		{
			if (!User::is_valid_hashed_password($hashed_password)) {
				throw new InvalidParamException("Fail setting password. Invalid new password.", 2);
			}

			$query = 'SELECT password FROM user WHERE id_user = :id;';
			$this->_db->query($query, array(':id' => $this->_id));
			$row = $this->_db->fetch();
			if ($row === false) {
				throw new DatabaseException("Fail testing password. `id_user` not found in database.");
			}
			if (strcmp($row['password'], $hashed_password) != 0) {
				return FALSE;
			}
			return TRUE;
		}
		public static function is_valid($user)
		{
			return gettype($user) === 'object' && get_class($user) === __CLASS__;
		}
		function is_logged($session)
		{
			if (!array_key_exists('user', $session) ||
				$session['user'] == null ||
				$session['user'] == "" ||
				!User::is_valid(unserialize($session['user'])))
			{
				return false;
			}
			return true;
		}

		/*
		** -------------------- Tools --------------------
		*/
		// public function link_cookie($id_cookie) {
		// 	if (!User::is_valid_id($id_cookie)) {
		// 		throw new InvalidParamException("Failed running " . __METHOD__ . ". Invalid id_cookie.", 1);
		// 	}
		//
		// 	// update db
		// 	$query = 'UPDATE cookie SET id_user = :idu WHERE id_cookie = :idc;';
		// 	$this->_db->query($query, array(':idu' => $this->_id, ':idc' => $id_cookie));
		// 	$modified_row_count = $this->_db->rowCount();
		// 	if ($modified_row_count !== 1) {
		// 		throw new DatabaseException("Fail linking cookie. " . $modified_row_count . " rows have been modified in the database.");
		// 	}
		// }
	}
?>
