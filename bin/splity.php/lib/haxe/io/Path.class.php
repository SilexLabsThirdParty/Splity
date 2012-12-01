<?php

class haxe_io_Path {
	public function __construct($path) {
		if(!php_Boot::$skip_constructor) {
		$c1 = _hx_last_index_of($path, "/", null);
		$c2 = _hx_last_index_of($path, "\\", null);
		if($c1 < $c2) {
			$this->dir = _hx_substr($path, 0, $c2);
			$path = _hx_substr($path, $c2 + 1, null);
			$this->backslash = true;
		} else {
			if($c2 < $c1) {
				$this->dir = _hx_substr($path, 0, $c1);
				$path = _hx_substr($path, $c1 + 1, null);
			} else {
				$this->dir = null;
			}
		}
		$cp = _hx_last_index_of($path, ".", null);
		if($cp !== -1) {
			$this->ext = _hx_substr($path, $cp + 1, null);
			$this->file = _hx_substr($path, 0, $cp);
		} else {
			$this->ext = null;
			$this->file = $path;
		}
	}}
	public function toString() {
		return (haxe_io_Path_0($this)) . $this->file . (haxe_io_Path_1($this));
	}
	public $backslash;
	public $file;
	public $dir;
	public $ext;
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
	static function withoutExtension($path) {
		$s = new haxe_io_Path($path);
		$s->ext = null;
		return $s->toString();
	}
	static function withoutDirectory($path) {
		$s = new haxe_io_Path($path);
		$s->dir = null;
		return $s->toString();
	}
	static function directory($path) {
		$s = new haxe_io_Path($path);
		if($s->dir === null) {
			return "";
		}
		return $s->dir;
	}
	static function extension($path) {
		$s = new haxe_io_Path($path);
		if($s->ext === null) {
			return "";
		}
		return $s->ext;
	}
	static function withExtension($path, $ext) {
		$s = new haxe_io_Path($path);
		$s->ext = $ext;
		return $s->toString();
	}
	function __toString() { return $this->toString(); }
}
function haxe_io_Path_0(&$»this) {
	if($»this->dir === null) {
		return "";
	} else {
		return $»this->dir . ((($»this->backslash) ? "\\" : "/"));
	}
}
function haxe_io_Path_1(&$»this) {
	if($»this->ext === null) {
		return "";
	} else {
		return "." . $»this->ext;
	}
}
