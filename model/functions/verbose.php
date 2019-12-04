<?php
	$verbose = false;

	function verbose($txt)
	{
		if ($verbose) {
			printf($txt);
		}
	}
	function rverbose($txt)
	{
		if ($verbose) {
			printf("return: `" . $txt . "`\n");
		}
		return $txt;
	}
?>
