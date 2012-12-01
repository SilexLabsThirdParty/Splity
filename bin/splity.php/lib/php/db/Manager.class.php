<?php

class php_db_Manager {
	public function __construct($classval) {
		if(!php_Boot::$skip_constructor) {
		$this->cls = $classval;
		$clname = Type::getClassName($this->cls);
		$this->table_name = $this->quoteField(php_db_Manager_0($this, $classval, $clname));
		$this->table_keys = php_db_Manager_1($this, $classval, $clname);
		$apriv = $this->cls->PRIVATE_FIELDS;
		$apriv = (($apriv === null) ? new _hx_array(array()) : $apriv->copy());
		$apriv->push("__cache__");
		$apriv->push("__noupdate__");
		$apriv->push("__manager__");
		$apriv->push("update");
		$this->table_fields = new HList();
		$stub = Type::createEmptyInstance($this->cls);
		$instance_fields = Type::getInstanceFields($this->cls);
		$scls = Type::getSuperClass($this->cls);
		while($scls !== null) {
			{
				$_g = 0; $_g1 = Type::getInstanceFields($scls);
				while($_g < $_g1->length) {
					$remove = $_g1[$_g];
					++$_g;
					$instance_fields->remove($remove);
					unset($remove);
				}
				unset($_g1,$_g);
			}
			$scls = Type::getSuperClass($scls);
		}
		{
			$_g = 0;
			while($_g < $instance_fields->length) {
				$f = $instance_fields[$_g];
				++$_g;
				$isfield = !Reflect::isFunction(Reflect::field($stub, $f));
				if($isfield) {
					$_g1 = 0;
					while($_g1 < $apriv->length) {
						$f2 = $apriv[$_g1];
						++$_g1;
						if($f === $f2) {
							$isfield = false;
							break;
						}
						unset($f2);
					}
					unset($_g1);
				}
				if($isfield) {
					$this->table_fields->add($f);
				}
				unset($isfield,$f);
			}
		}
		php_db_Manager::$managers->set($clname, $this);
		$rl = null;
		try {
			$rl = $this->cls->RELATIONS();
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
				$this->table_fields->remove($r->prop);
				$this->table_fields->remove("get_" . Std::string($r->prop));
				$this->table_fields->remove("set_" . Std::string($r->prop));
				$this->table_fields->remove($r->key);
				$this->table_fields->add($r->key);
				unset($r);
			}
		}
	}}
	public function getFromCache($x, $lock) {
		$c = php_db_Manager::$object_cache->get($this->makeCacheKey($x));
		if($c !== null && $lock && $c->__noupdate__) {
			$c->__noupdate__ = false;
		}
		return $c;
	}
	public function addToCache($x) {
		php_db_Manager::$object_cache->set($this->makeCacheKey($x), $x);
	}
	public function makeCacheKey($x) {
		if($this->table_keys->length === 1) {
			$k = Reflect::field($x, $this->table_keys[0]);
			if($k === null) {
				throw new HException("Missing key " . $this->table_keys[0]);
			}
			return Std::string($k) . $this->table_name;
		}
		$s = new StringBuf();
		{
			$_g = 0; $_g1 = $this->table_keys;
			while($_g < $_g1->length) {
				$k = $_g1[$_g];
				++$_g;
				$v = Reflect::field($x, $k);
				if($k === null) {
					throw new HException("Missing key " . $k);
				}
				$s->add($v);
				$s->add("#");
				unset($v,$k);
			}
		}
		$s->add($this->table_name);
		return $s->b;
	}
	public function initRelation($o, $r) {
		$manager = $r->manager;
		$hkey = $r->key;
		$lock = $r->lock;
		if($lock === null) {
			$lock = true;
		}
		if($manager === null || $manager->table_keys === null) {
			throw new HException("Invalid manager for relation " . $this->table_name . ":" . $r->prop);
		}
		if($manager->table_keys->length !== 1) {
			throw new HException("Relation " . $r->prop . "(" . $r->key . ") on a multiple key table");
		}
		$o->{"get_" . $r->prop} = array(new _hx_lambda(array(&$hkey, &$lock, &$manager, &$o, &$r), "php_db_Manager_2"), 'execute');
		$o->{"set_" . $r->prop} = array(new _hx_lambda(array(&$hkey, &$lock, &$manager, &$o, &$r), "php_db_Manager_3"), 'execute');
	}
	public function dbClass() {
		return $this->cls;
	}
	public function objects($sql, $lock) {
		$me = $this;
		$l = php_db_Manager::$cnx->request($sql)->results();
		$l2 = new HList();
		if(null == $l) throw new HException('null iterable');
		$»it = $l->iterator();
		while($»it->hasNext()) {
			$x = $»it->next();
			$c = $this->getFromCache($x, $lock);
			if($c !== null) {
				$l2->add($c);
			} else {
				$o = $this->cacheObject($x, $lock);
				$this->make($o);
				$l2->add($o);
				unset($o);
			}
			unset($c);
		}
		return $l2;
	}
	public function object($sql, $lock) {
		$r = php_db_Manager::$cnx->request($sql)->next();
		if($r === null) {
			return null;
		}
		$c = $this->getFromCache($r, $lock);
		if($c !== null) {
			return $c;
		}
		$o = $this->cacheObject($r, $lock);
		$this->make($o);
		return $o;
	}
	public function selectReadOnly($cond) {
		$s = new StringBuf();
		$s->add("SELECT * FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$s->add($cond);
		return $s->b;
	}
	public function select($cond) {
		$s = new StringBuf();
		$s->add("SELECT * FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$s->add($cond);
		$s->add(php_db_Manager::$FOR_UPDATE);
		return $s->b;
	}
	public function execute($sql) {
		return php_db_Manager::$cnx->request($sql);
	}
	public function addKeys($s, $x) {
		$first = true;
		{
			$_g = 0; $_g1 = $this->table_keys;
			while($_g < $_g1->length) {
				$k = $_g1[$_g];
				++$_g;
				if($first) {
					$first = false;
				} else {
					$s->add(" AND ");
				}
				$s->add($this->quoteField($k));
				$s->add(" = ");
				$f = Reflect::field($x, $k);
				if($f === null) {
					throw new HException("Missing key " . $k);
				}
				php_db_Manager::$cnx->addValue($s, $f);
				unset($k,$f);
			}
		}
	}
	public function quoteField($f) {
		$fsmall = strtolower($f);
		if($fsmall === "read" || $fsmall === "desc" || $fsmall === "out" || $fsmall === "group" || $fsmall === "version" || $fsmall === "option") {
			return "`" . $f . "`";
		}
		return $f;
	}
	public function unmake($x) {
	}
	public function make($x) {
	}
	public function cacheObject($x, $lock) {
		$o = Type::createEmptyInstance($this->cls);
		{
			$_g = 0; $_g1 = Reflect::fields($x);
			while($_g < $_g1->length) {
				$field = $_g1[$_g];
				++$_g;
				$o->{$field} = Reflect::field($x, $field);
				unset($field);
			}
		}
		$o->__init_object();
		$this->addToCache($o);
		$o->{php_db_Manager::$cache_field} = Type::createEmptyInstance($this->cls);
		if(!$lock) {
			$o->__noupdate__ = true;
		}
		return $o;
	}
	public function objectToString($it) {
		$s = new StringBuf();
		$s->add($this->table_name);
		if($this->table_keys->length === 1) {
			$s->add("#");
			$s->add(Reflect::field($it, $this->table_keys[0]));
		} else {
			$s->add("(");
			$first = true;
			{
				$_g = 0; $_g1 = $this->table_keys;
				while($_g < $_g1->length) {
					$f = $_g1[$_g];
					++$_g;
					if($first) {
						$first = false;
					} else {
						$s->add(",");
					}
					$s->add($this->quoteField($f));
					$s->add(":");
					$s->add(Reflect::field($it, $f));
					unset($f);
				}
			}
			$s->add(")");
		}
		return $s->b;
	}
	public function doSync($i) {
		php_db_Manager::$object_cache->remove($this->makeCacheKey($i));
		$i2 = $this->getWithKeys($i, !$i->__noupdate__);
		{
			$_g = 0; $_g1 = Reflect::fields($i);
			while($_g < $_g1->length) {
				$f = $_g1[$_g];
				++$_g;
				Reflect::deleteField($i, $f);
				unset($f);
			}
		}
		{
			$_g = 0; $_g1 = Reflect::fields($i2);
			while($_g < $_g1->length) {
				$f = $_g1[$_g];
				++$_g;
				$i->{$f} = Reflect::field($i2, $f);
				unset($f);
			}
		}
		$i->{php_db_Manager::$cache_field} = Reflect::field($i2, php_db_Manager::$cache_field);
		$this->addToCache($i);
	}
	public function doDelete($x) {
		$s = new StringBuf();
		$s->add("DELETE FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$this->addKeys($s, $x);
		$this->execute($s->b);
	}
	public function doUpdate($x) {
		$this->unmake($x);
		$s = new StringBuf();
		$s->add("UPDATE ");
		$s->add($this->table_name);
		$s->add(" SET ");
		$cache = Reflect::field($x, php_db_Manager::$cache_field);
		if(null === $cache) {
			$cache = $this->cacheObject($x, false);
			$x->{php_db_Manager::$cache_field} = $cache;
		}
		$mod = false;
		if(null == $this->table_fields) throw new HException('null iterable');
		$»it = $this->table_fields->iterator();
		while($»it->hasNext()) {
			$f = $»it->next();
			$v = Reflect::field($x, $f);
			$vc = Reflect::field($cache, $f);
			if(!_hx_equal($v, $vc)) {
				if($mod) {
					$s->add(", ");
				} else {
					$mod = true;
				}
				$s->add($this->quoteField($f));
				$s->add(" = ");
				php_db_Manager::$cnx->addValue($s, $v);
				$cache->{$f} = $v;
			}
			unset($vc,$v);
		}
		if(!$mod) {
			return;
		}
		$s->add(" WHERE ");
		$this->addKeys($s, $x);
		$this->execute($s->b);
	}
	public function doInsert($x) {
		$this->unmake($x);
		$s = new StringBuf();
		$fields = new HList();
		$values = new HList();
		if(null == $this->table_fields) throw new HException('null iterable');
		$»it = $this->table_fields->iterator();
		while($»it->hasNext()) {
			$f = $»it->next();
			$v = Reflect::field($x, $f);
			if($v !== null) {
				$fields->add($this->quoteField($f));
				$values->add($v);
			}
			unset($v);
		}
		$s->add("INSERT INTO ");
		$s->add($this->table_name);
		$s->add(" (");
		$s->add($fields->join(","));
		$s->add(") VALUES (");
		$first = true;
		if(null == $values) throw new HException('null iterable');
		$»it = $values->iterator();
		while($»it->hasNext()) {
			$v = $»it->next();
			if($first) {
				$first = false;
			} else {
				$s->add(", ");
			}
			php_db_Manager::$cnx->addValue($s, $v);
		}
		$s->add(")");
		$this->execute($s->b);
		if($this->table_keys->length === 1 && Reflect::field($x, $this->table_keys[0]) === null) {
			$x->{$this->table_keys[0]} = php_db_Manager::$cnx->lastInsertId();
		}
		$this->addToCache($x);
	}
	public function results($sql) {
		return php_db_Manager::$cnx->request($sql)->results();
	}
	public function result($sql) {
		return php_db_Manager::$cnx->request($sql)->next();
	}
	public function quote($s) {
		return php_db_Manager::$cnx->quote($s);
	}
	public function count($x = null) {
		$s = new StringBuf();
		$s->add("SELECT COUNT(*) FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$this->addCondition($s, $x);
		return $this->execute($s->b)->getIntResult(0);
	}
	public function all($lock = null) {
		if($lock === null) {
			$lock = true;
		}
		return $this->objects("SELECT * FROM " . $this->table_name . (php_db_Manager_4($this, $lock)), $lock);
	}
	public function addCondition($s, $x) {
		$first = true;
		if($x !== null) {
			$_g = 0; $_g1 = Reflect::fields($x);
			while($_g < $_g1->length) {
				$f = $_g1[$_g];
				++$_g;
				if($first) {
					$first = false;
				} else {
					$s->add(" AND ");
				}
				$s->add($this->quoteField($f));
				$d = Reflect::field($x, $f);
				if($d === null) {
					$s->add(" IS NULL");
				} else {
					$s->add(" = ");
					php_db_Manager::$cnx->addValue($s, $d);
				}
				unset($f,$d);
			}
		}
		if($first) {
			$s->add("1");
		}
	}
	public function search($x, $lock = null) {
		if($lock === null) {
			$lock = true;
		}
		$s = new StringBuf();
		$s->add("SELECT * FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$this->addCondition($s, $x);
		if($lock) {
			$s->add(php_db_Manager::$FOR_UPDATE);
		}
		return $this->objects($s->b, $lock);
	}
	public function delete($x) {
		$s = new StringBuf();
		$s->add("DELETE FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$this->addCondition($s, $x);
		$this->execute($s->b);
	}
	public function getWithKeys($keys, $lock = null) {
		if($lock === null) {
			$lock = true;
		}
		$x = $this->getFromCache($keys, false);
		if($x !== null && (!$lock || !$x->__noupdate__)) {
			return $x;
		}
		$s = new StringBuf();
		$s->add("SELECT * FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$this->addKeys($s, $keys);
		if($lock) {
			$s->add(php_db_Manager::$FOR_UPDATE);
		}
		return $this->object($s->b, $lock);
	}
	public function get($id, $lock = null) {
		if($lock === null) {
			$lock = true;
		}
		if($this->table_keys->length !== 1) {
			throw new HException("Invalid number of keys");
		}
		if($id === null) {
			return null;
		}
		$x = php_db_Manager::$object_cache->get(_hx_string_rec($id, "") . $this->table_name);
		if($x !== null && (!$lock || !$x->__noupdate__)) {
			return $x;
		}
		$s = new StringBuf();
		$s->add("SELECT * FROM ");
		$s->add($this->table_name);
		$s->add(" WHERE ");
		$s->add($this->quoteField($this->table_keys[0]));
		$s->add(" = ");
		php_db_Manager::$cnx->addValue($s, $id);
		if($lock) {
			$s->add(php_db_Manager::$FOR_UPDATE);
		}
		return $this->object($s->b, $lock);
	}
	public $cls;
	public $table_keys;
	public $table_fields;
	public $table_name;
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
	static $cnx;
	static $object_cache;
	static $cache_field = "__cache__";
	static $FOR_UPDATE = "";
	static $managers;
	static function setConnection($c) { return call_user_func_array(self::$setConnection, array($c)); }
	public static $setConnection = null;
	static function initialize() {
	}
	static function cleanup() {
		php_db_Manager::$object_cache = new Hash();
	}
	static $__properties__ = array("set_cnx" => "setConnection");
	function __toString() { return 'php.db.Manager'; }
}
php_db_Manager::$object_cache = new Hash();
php_db_Manager::$managers = new Hash();
php_db_Manager::$setConnection = array(new _hx_lambda(array(), "php_db_Manager_5"), 'execute');
function php_db_Manager_0(&$»this, &$classval, &$clname) {
	if(_hx_field($»this->cls, "TABLE_NAME") !== null) {
		return $»this->cls->TABLE_NAME;
	} else {
		return _hx_explode(".", $clname)->pop();
	}
}
function php_db_Manager_1(&$»this, &$classval, &$clname) {
	if(_hx_field($»this->cls, "TABLE_IDS") !== null) {
		return $»this->cls->TABLE_IDS;
	} else {
		return new _hx_array(array("id"));
	}
}
function php_db_Manager_2(&$hkey, &$lock, &$manager, &$o, &$r) {
	{
		return $manager->get(Reflect::field($o, $hkey), $lock);
	}
}
function php_db_Manager_3(&$hkey, &$lock, &$manager, &$o, &$r, $f) {
	{
		$o->{$hkey} = Reflect::field($f, $manager->table_keys[0]);
		return $f;
	}
}
function php_db_Manager_4(&$»this, &$lock) {
	if($lock) {
		return php_db_Manager::$FOR_UPDATE;
	} else {
		return "";
	}
}
function php_db_Manager_5($c) {
	{
		_hx_qtype("php.db.Manager")->{"cnx"} = $c;
		if($c !== null) {
			php_db_Manager::$FOR_UPDATE = (($c->dbName() === "MySQL") ? " FOR UPDATE" : "");
		}
		return $c;
	}
}
