<?php

class php_db__Sqlite_SqliteResultSet implements sys_db_ResultSet{
	public function __construct($r) {
		if(!php_Boot::$skip_constructor) {
		$this->r = $r;
	}}
	public function getFieldsNames() {
		php_db__Sqlite_SqliteResultSet_0($this);
	}
	public function getFloatResult($n) {
		return floatval($this->getResult($n));
	}
	public function getIntResult($n) {
		return intval($this->getResult($n));
	}
	public function getResult($n) {
		if($this->cRow === null && !$this->fetchRow()) {
			return null;
		}
		return _hx_array_get(array_values($this->cRow), $n);
	}
	public function results() {
		$l = new HList();
		while(true) {
			$c = $this->next();
			if($c === null) {
				break;
			}
			$l->add($c);
			unset($c);
		}
		return $l;
	}
	public function next() {
		if(_hx_field($this, "cache") !== null) {
			$t = $this->cache;
			$this->cache = null;
			return $t;
		}
		if(!$this->fetchRow()) {
			return null;
		}
		return _hx_anonymous($this->cRow);
	}
	public function fetchRow() {
		$this->cRow = sqlite_fetch_array($this->r, SQLITE_ASSOC);
		return !($this->cRow === false);
	}
	public $cRow;
	public function hasNext() {
		if(_hx_field($this, "cache") === null) {
			$this->cache = $this->next();
		}
		return _hx_field($this, "cache") !== null;
	}
	public function getNFields() {
		if($this->_nfields === null) {
			$this->_nfields = sqlite_num_fields($this->r);
		}
		return $this->_nfields;
	}
	public $_nfields;
	public function getLength() {
		if(($this->r === true)) {
			return sqlite_changes($this->r);
		} else {
			if(($this->r === false)) {
				return 0;
			}
		}
		return sqlite_num_rows($this->r);
	}
	public $cache;
	public $r;
	public $nfields;
	public $length;
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	static $__properties__ = array("get_length" => "getLength","get_nfields" => "getNFields");
	function __toString() { return 'php.db._Sqlite.SqliteResultSet'; }
}
function php_db__Sqlite_SqliteResultSet_0(&$»this) {
	throw new HException("Not implemented");
}
