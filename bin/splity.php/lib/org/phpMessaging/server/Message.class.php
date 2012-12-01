<?php

class org_phpMessaging_server_Message {
	public function __construct($clientId = null, $applicationId = null, $metaData = null, $type = null) {
		if(!php_Boot::$skip_constructor) {
		if($type === null) {
			$type = "";
		}
		$this->messageData = new org_phpMessaging_model_MessageData();
		$this->messageData->clientId = $clientId;
		$this->messageData->applicationId = $applicationId;
		$this->messageData->metaData = $metaData;
		$this->messageData->type = $type;
	}}
	public function getMetaData($name) {
		if(_hx_field($this->messageData, "metaData") === null) {
			return null;
		}
		return Reflect::field($this->messageData->metaData, $name);
	}
	public function setMetaData($name, $value) {
		if(_hx_field($this->messageData, "metaData") === null) {
			$this->messageData->metaData = _hx_anonymous(array());
		}
		$this->messageData->metaData->{$name} = $value;
		$this->messageData->update();
	}
	public function send() {
		$this->messageData->time = Date::now();
		$this->messageData->insert();
	}
	public $messageData;
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
	function __toString() { return 'org.phpMessaging.server.Message'; }
}
