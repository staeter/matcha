<?php
	// require_once "../../model/functions/verbose.php";
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/exceptions/DatabaseException.class.php';

	class Database implements Serializable {
		private $_db;
		private $_statement;

		private $_dsn;
		private $_username;
		private $_password;

		// --- serializable ---

		public function serialize()
	    {
	        return serialize([
	            $this->_dsn,
	            $this->_username,
				$this->_password
	        ]);
	    }

	    public function unserialize($data)
	    {
	        list(
	            $this->_dsn,
	            $this->_username,
				$this->_password
	        ) = unserialize($data);

			try {
			    $this->_db = new PDO(
					$this->_dsn,
					$this->_username,
					$this->_password,
					array(PDO::ATTR_PERSISTENT => TRUE, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
				);
			} catch(PDOException $e) {
				throw new DatabaseException("Failed constructing " . __CLASS__ . " while unserialize. PDO instanciation failed:\n" . $e->getMessage());
			}
	    }

		// --- construct ---

		public function __construct($dsn, $username, $password)
		{
			// verbose("Database::__construct(" . $dsn . ", " . $username . ", " . $password . ")");

			try {
			    $this->_db = new PDO(
					$dsn,
					$username,
					$password,
					array(PDO::ATTR_PERSISTENT => TRUE, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
				);
			} catch(PDOException $e) {
				throw new DatabaseException("Failed constructing " . __CLASS__ . ". PDO instanciation failed:\n" . $e->getMessage());
			}

			$this->_dsn = $dsn;
			$this->_username = $username;
			$this->_password = $password;
		}

		public function __destruct()
		{
			// verbose("Database::__destruct()");

			$this->_db = null;
		}

		public function query($query, $bindValues)
		{
			// verbose("Database::query(" . $query . ", bv_array)\nbv_array: " . json_encode($bindValues) . "\n");

			// prepare
			try {
				$this->_statement = $this->_db->prepare($query);
			} catch (PDOException $e) {
				throw new DatabaseException("Failed querying " . __CLASS__ . ". Invalid query:\n" . $e->getMessage());
			}

			// execute statement and return
			if ($this->_statement->execute($bindValues) === FALSE) {
				throw new DatabaseException("Failed querying " . __CLASS__ . ". Execution failed:\n" . $e->getMessage());
			}
		}

		public function exec($sql)
		{
			// verbose("Database::exec(" . $sql . ")\n");

			return $this->_db->exec($sql);
		}

		public function fetch()
		{
			try {
				return $this->_statement->fetch(PDO::FETCH_ASSOC);
			}
			catch (PDOException $e) {
				throw new DatabaseException("Failed fetching " . __CLASS__ . ". Execution failed:\n" . $e->getMessage());
			}
		}

		public function fetchAll()
		{
			try {
				return $this->_statement->fetchAll(PDO::FETCH_ASSOC);
			}
			catch (PDOException $e) {
				throw new DatabaseException("Failed fetching all " . __CLASS__ . ". Execution failed:\n" . $e->getMessage());
			}
		}

		public function rowCount()
		{
			return $this->_statement->rowCount();
		}

		public static function is_valid($db)
		{
			return gettype($db) === 'object' && get_class($db) === __CLASS__;
		}
	}
?>
