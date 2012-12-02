<?php

class org_phpMessaging_model_MessageData extends php_db_Object {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $metaDataSerialized;
	public $metaData;
	public $time;
	public $applicationId;
	public $clientId;
	public $type;
	public $id;
	public function toDataModel() {
		return _hx_anonymous(array("id" => $this->id, "type" => $this->type, "clientId" => $this->clientId, "applicationId" => $this->applicationId, "time" => $this->time, "metaData" => $this->metaData));
	}
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
	static $TYPE_CLIENT_CREATED = "TYPE_NEW_CLIENT";
	static $TYPE_CLIENT_DELETED = "TYPE_CLIENT_DELETED";
	static $TYPE_CLIENT_DISPATCH = "TYPE_CLIENT_DISPATCH";
	static $TABLE_NAME = "MessageData";
	static $PRIVATE_FIELDS;
	static $manager;
	function __toString() { return 'org.phpMessaging.model.MessageData'; }
}
org_phpMessaging_model_MessageData::$PRIVATE_FIELDS = new _hx_array(array("metaData"));
org_phpMessaging_model_MessageData::$manager = new org_phpMessaging_server_database_MessageDataManager();
