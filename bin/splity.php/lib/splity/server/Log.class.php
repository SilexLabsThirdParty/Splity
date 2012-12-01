<?php

class splity_server_Log {
	public function __construct(){}
	static $LOG_FILE_PATH = "../splity.log";
	static function trace($str) {
		$output = sys_io_File::getContent("../splity.log") . "\x0A" . Std::string(Date::now()) . " - " . $str;
		sys_io_File::saveContent("../splity.log", $output);
	}
	function __toString() { return 'splity.server.Log'; }
}
