<?php

interface sys_db_Connection {
	function rollback();
	function commit();
	function startTransaction();
	function dbName();
	function lastInsertId();
	function addValue($s, $v);
	function quote($s);
	function escape($s);
	function close();
	function request($s);
}
