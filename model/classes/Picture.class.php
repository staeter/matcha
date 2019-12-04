<?php
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';

	class Picture implements Serializable{
		private $_id;
		private $_user_id;
		private $_user_pseudo;
		private $_path;
		private $_public;
		private $_date;
		private $_db;

		/*
		** -------------------- Serialize --------------------
		*/
		public function serialize()
	    {
	        return serialize([
	            $this->_id,
	            $this->_user_id,
	            $this->_user_pseudo,
				$this->_path,
	            $this->_public,
	            $this->_date,
				$this->_db
	        ]);
	    }

	    public function unserialize($data)
	    {
	        list(
	            $this->_id,
	            $this->_user_id,
	            $this->_user_pseudo,
				$this->_path,
	            $this->_public,
	            $this->_date,
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
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Wrong amount of parameters ($i).\n", 0);
			}
		}

		private function __construct2($id_picture, $db)
		{
			if (!Picture::is_valid_id($id_picture)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid id.\n", 21);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid db object.\n", 22);
			}

			// query from database
			$query = "SELECT picture.id_picture, picture.path, picture.public, picture.date, user.id_user, user.pseudo FROM user JOIN picture ON picture.id_user = user.id_user WHERE id_picture = :idp;";
			$db->query($query, array(':idp' => $id_picture));
			$row = $db->fetch();
			if ($row === false) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". id_picture not found in database.\n", 20);
			}

			// set object properties
			$this->_id = $row['id_picture'];
			$this->_user_id = $row['id_user'];
			$this->_user_pseudo = $row['pseudo'];
			$this->_path = $row['path'];
			$this->_public = $row['public'];
			$this->_date = $row['date'];
			$this->_db = $db;
		}

		private function __construct3($path, $user, $db)
		{
			// test parameters validity
			if (!Picture::is_valid_path($path)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid path.\n", 41);
			}
			if (!User::is_valid($user)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid user.\n", 42);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . ". Invalid db object.\n", 43);
			}

			// adding new user to database and pull the id_user
			$query = 'INSERT INTO picture (`id_user`, `path`) VALUES (:idu, :p);';
			$db->query($query, array(':idu' => $user->get_id(), ':p' => $path));
			$query = 'SELECT `id_picture`, user.id_user, `pseudo`, `public`, `date` FROM picture JOIN user ON picture.id_user = user.id_user WHERE id_picture = LAST_INSERT_ID();';
			$db->query($query, array());
			$row = $db->fetch();
			if ($row === false) {
				throw new DatabaseException("Failed constructing " . __CLASS__ . ". Id not pulled from db.\n");
			}

			// set object properties
			$this->_id = $row['id_picture'];
			$this->_user_id = $row['id_user'];
			$this->_user_pseudo = $row['pseudo'];
			$this->_path = $path;
			$this->_public = $row['public'];
			$this->_date = $row['date'];
			$this->_db = $db;
		}

		/*
		** -------------------- Construct --------------------
		*/

		public function delete($owner) {
			if (!User::is_valid($owner)) {
				throw new InvalidParamException("Failed deleting " . __CLASS__ . ". Invalid user.\n", 1);
			}
			if ($owner->get_id() !== $this->get_user_id()) {
				throw new InvalidParamException("Failed deleting " . __CLASS__ . ". This picture isn't owned by that user.\n", 1);
			}

			// adding new user to database and pull the id_user
			$query = 'DELETE FROM picture WHERE id_picture = :idp;';
			$this->_db->query($query, array(':idp' => $this->get_id()));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail deleting picture. " . $modified_row_count . " rows have been modified in the database.\n");
			}
		}


		/*
		** -------------------- Special functions --------------------
		*/

		public function __destruct()
		{
			$this->_id = null;
			$this->_user_id = null;
			$this->_user_pseudo = null;
			$this->_path = null;
			$this->_date = null;
			$this->_db = null;
		}
		public function __toString()
		{
			return $this->_path;
		}


		/*
		** -------------------- Basic gets --------------------
		*/
		public function get_id()
		{
			return $this->_id;
		}
		public function get_user_id()
		{
			return $this->_user_id;
		}
		public function get_user_pseudo()
		{
			return $this->_user_pseudo;
		}
		public function get_path()
		{
			return $this->_path;
		}
		public function get_date()
		{
			return $this->_date;
		}
		public function get_likes()
		{
			// query from database
			$query = "SELECT COUNT(id_user) AS likes FROM `like` WHERE id_picture = :idp;";
			$this->_db->query($query, array(':idp' => $this->get_id()));
			$row = $this->_db->fetch();
			return $row['likes'];
		}
		public function get_comment_amount()
		{
			// query from database
			$query = "SELECT COUNT(id_comment) AS comments_amount FROM `comment` WHERE id_picture = :idp;";
			$this->_db->query($query, array(':idp' => $this->get_id()));
			$row = $this->_db->fetch();
			return $row['comments_amount'];
		}


		/*
		** -------------------- Is --------------------
		*/
		public function is_public()
		{
			return $this->_public ? TRUE : FALSE;
		}
		public static function is_valid($picture)
		{
			return (gettype($picture) === 'object'
			&& get_class($picture) === __CLASS__
			&& Picture::is_valid_id($picture->get_id())
			&& User::is_valid_id($picture->get_user_id())
			&& User::is_valid_pseudo($picture->get_user_pseudo())
			&& Picture::is_valid_path($picture->get_path())
			&& $picture->is_public() != null
			&& $picture->get_date() != null);
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
		public static function is_valid_path($path)
		{
			$patern = "/^[a-zA-Z0-9_]+\.(jpg|png)$/";
			return preg_match($patern, $path) ? TRUE : FALSE;
		}

		/*
		** --- Set ---
		*/
		public function set_public()
		{
			$query = 'UPDATE picture SET `public` = :p WHERE id_picture = :id;';
			$this->_db->query($query, array(':p' => $this->is_public() ? '0' : '1', ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting public. " . $modified_row_count . " rows have been modified in the database.\n");
			}

			$this->_public = !$this->is_public();
		}
		public function set_path($new_path)
		{
			$query = 'UPDATE picture SET `path` = :p WHERE id_picture = :id;';
			$this->_db->query($query, array(':p' => $new_path, ':id' => $this->_id));
			$modified_row_count = $this->_db->rowCount();
			if ($modified_row_count !== 1) {
				throw new DatabaseException("Fail setting path. " . $modified_row_count . " rows have been modified in the database.\n");
			}

			$this->_path = $new_path;
		}

		/*
		** -------------------- Advenced gets --------------------
		*/
		public static function get_most_recent_public($db)
		{
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . " in get_most_recent_public. Invalid db object.\n", 1);
			}

			$query = "SELECT max(id_picture) AS id_picture FROM picture WHERE public = true;";
			$db->query($query, array());
			$row = $db->fetch();
			if ($row === false) {
				throw new DatabaseException(__CLASS__ . "::get_most_recent_public failed. Id not pulled from db.\n");
			}

			return new Picture($row['id_picture'], $db);
		}
		public function get_next_public()
		{
			$query = "SELECT max(id_picture) AS id_picture FROM picture WHERE public = true AND id_picture < :idp;";
			$this->_db->query($query, array(':idp' => $this->_id));
			$row = $this->_db->fetch();
			if ($row === false) {
				throw new DatabaseException(__CLASS__ . "::get_next_public failed. Id not pulled from db.\n");
			}
			if ($row['id_picture'] == null) {
				return FALSE;
			}

			return new Picture($row['id_picture'], $this->_db);
		}
		public static function get_most_recent_from_user($user, $db)
		{
			if (!User::is_valid($user)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . " in get_most_recent_from_user. Invalid user.\n", 1);
			}
			if (!Database::is_valid($db)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . " in get_most_recent_from_user. Invalid db object.\n", 2);
			}

			$query = "SELECT max(id_picture) AS id_picture FROM picture WHERE id_user = :idu;";
			$db->query($query, array(':idu' => $user->get_id()));
			$row = $db->fetch();
			if ($row === false) {
				throw new DatabaseException(__CLASS__ . "::get_most_recent_from_user failed. Id not pulled from db.\n");
			}

			return new Picture($row['id_picture'], $db);
		}
		public function get_next_from_user($user)
		{
			if (!User::is_valid($user)) {
				throw new InvalidParamException("Failed constructing " . __CLASS__ . " in get_next_from_user. Invalid user.\n", 1);
			}

			$query = "SELECT max(id_picture) AS id_picture FROM picture WHERE id_user = :idu AND id_picture < :idp;";
			$this->_db->query($query, array(':idu' => $user->get_id(), ':idp' => $this->_id));
			$row = $this->_db->fetch();
			if ($row === false) {
				throw new DatabaseException(__CLASS__ . "::get_next_from_user failed. Id not pulled from db.\n");
			}
			if ($row['id_picture'] == null) {
				return FALSE;
			}

			return new Picture($row['id_picture'], $this->_db);
		}

		/*
		** --- like and comment ---
		*/
		// output format: array(array('id' => ..., 'content' => ..., 'pseudo' => ..., 'date' => ...), ...)
		public function get_comments()
		{
			$query = "SELECT id_comment AS id, content, pseudo, comment.`date` AS `date` FROM comment JOIN user ON comment.id_user = user.id_user WHERE id_picture = :idp ORDER BY comment.`date` ASC;";
			$this->_db->query($query, array(':idp' => $this->get_id()));
			$row = $this->_db->fetchAll();
			return $row;
		}
		public function add_comment($usr, $content)
		{
			if (!User::is_valid($usr)) {
				throw new InvalidParamException("Failed liking " . __CLASS__ . ". Invalid user.\n", 1);
			}

			try {
				$query = 'INSERT INTO `comment` (`id_user`, `id_picture`, `content`) VALUES (:idu, :idp, :c);';
				$this->_db->query($query, array(':idu' => $usr->get_id(), ':idp' => $this->get_id(), ':c' => $content));
			} catch (Exception $e) {
				echo $e;
			}
		}
		public function like($usr)
		{
			if (!User::is_valid($usr)) {
				throw new InvalidParamException("Failed liking " . __CLASS__ . ". Invalid user.\n", 1);
			}

			try {

				// try to add row into db
				$query = 'INSERT INTO `like` (`id_user`, `id_picture`) VALUES (:idu, :idp);';
				$this->_db->query($query, array(':idu' => $usr->get_id(), ':idp' => $this->_id));

			} catch (Exception $e) {
				if ($e->getCode() == 23000) {

					// if the row alredy exists delete it
					$query = 'DELETE FROM `like` WHERE id_picture = :idp AND id_user = :idu;';
					$this->_db->query($query, array(':idp' => $this->get_id(), ':idu' => $usr->get_id()));

					// if a problem happened on deletion throw DatabaseException
					$modified_row_count = $this->_db->rowCount();
					if ($modified_row_count !== 1) {
						throw new DatabaseException("Fail deleting like. " . $modified_row_count . " rows have been modified in the database.\n");
					}

				} else {
					throw $e;
				}
			}
		}
	}
?>
