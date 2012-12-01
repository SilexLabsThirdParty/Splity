<?php

class org_phpMessaging_server_database_DatabaseConnection {
	public function __construct() { 
	}
	static $_connection;
	static function open($host, $port = null, $database = null, $user = null, $pass = null, $socket = null) {
		if($pass === null) {
			$pass = "";
		}
		if($user === null) {
			$user = "root";
		}
		if($port === null) {
			$port = 3306;
		}
		$useMysql = $database !== null;
		if(!$useMysql) {
			org_phpMessaging_server_database_DatabaseConnection::$_connection = php_db_Sqlite::open($host);
		} else {
			org_phpMessaging_server_database_DatabaseConnection::$_connection = php_db_Mysql::connect(_hx_anonymous(array("host" => $host, "port" => $port, "database" => $database, "user" => $user, "pass" => $pass, "socket" => $socket)));
		}
		php_db_Manager::setConnection(org_phpMessaging_server_database_DatabaseConnection::$_connection);
		php_db_Manager::initialize();
	}
	static function close() {
		php_db_Manager::cleanup();
		org_phpMessaging_server_database_DatabaseConnection::$_connection->close();
	}
	function __toString() { return 'org.phpMessaging.server.database.DatabaseConnection'; }
}
