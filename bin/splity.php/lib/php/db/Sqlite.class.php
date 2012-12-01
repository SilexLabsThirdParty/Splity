<?php

class php_db_Sqlite {
	public function __construct(){}
	static function open($file) {
		return new php_db__Sqlite_SqliteConnection($file);
	}
	function __toString() { return 'php.db.Sqlite'; }
}
