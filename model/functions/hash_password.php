<?php
	function hash_password($password)
	{
		return hash('sha512', $password);
	}
?>
