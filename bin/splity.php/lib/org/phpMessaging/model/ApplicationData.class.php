<?php

class org_phpMessaging_model_ApplicationData extends php_db_Object {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $metaDataSerialized;
	public $metaData;
	public $lastActivity;
	public $time;
	public $instanceName;
	public $name;
	public $id;
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
	static $TABLE_NAME = "ApplicationData";
	static $PRIVATE_FIELDS;
	static $manager;
	function __toString() { return 'org.phpMessaging.model.ApplicationData'; }
}
org_phpMessaging_model_ApplicationData::$PRIVATE_FIELDS = new _hx_array(array("metaData"));
org_phpMessaging_model_ApplicationData::$manager = new org_phpMessaging_server_database_ApplicationDataManager();
