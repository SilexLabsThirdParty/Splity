<?php

class php_db_Object {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->__init_object();
	}}
	public function toString() {
		return $this->__manager__->objectToString($this);
	}
	public function delete() {
		$this->__manager__->doDelete($this);
	}
	public function sync() {
		$this->__manager__->doSync($this);
	}
	public function update() {
		if($this->__noupdate__) {
			throw new HException("Cannot update not locked object");
		}
		$this->__manager__->doUpdate($this);
	}
	public function insert() {
		$this->__manager__->doInsert($this);
	}
	public function __init_object() {
		$this->__noupdate__ = false;
		$this->__manager__ = php_db_Manager::$managers->get(Type::getClassName(Type::getClass($this)));
		$rl = null;
		try {
			$rl = $this->__manager__->cls->RELATIONS();
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e = $_ex_;
			{
				return;
			}
		}
		{
			$_g = 0;
			while($_g < $rl->length) {
				$r = $rl[$_g];
				++$_g;
				$this->__manager__->initRelation($this, $r);
				unset($r);
			}
		}
	}
	public $__manager__;
	public $__noupdate__;
	public $__cache__;
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
	function __toString() { return $this->toString(); }
}
