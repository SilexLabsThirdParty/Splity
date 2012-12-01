<?php

class org_phpMessaging_server_Client {
	public function __construct($applicationId, $metaData = null) {
		if(!php_Boot::$skip_constructor) {
		if(php_Session::get("clientID") !== null) {
			$this->clientData = org_phpMessaging_model_ClientData::$manager->get(php_Session::get("clientID"), null);
		}
		if($this->clientData === null) {
			$this->clientData = new org_phpMessaging_model_ClientData();
			$this->clientData->applicationId = $applicationId;
			$this->clientData->time = Date::now();
			$this->clientData->lastActivity = Date::now();
			$this->clientData->metaData = $metaData;
			$this->clientData->insert();
			php_Session::clear();
			php_Session::set("clientID", $this->clientData->id);
			$message = new org_phpMessaging_server_Message(null, $applicationId, $this->clientData->toDataModel(), null);
			$message->messageData->type = "TYPE_NEW_CLIENT";
			$message->send();
		}
	}}
	public function getMetaData($name) {
		if(_hx_field($this->clientData, "metaData") === null) {
			return null;
		}
		return Reflect::field($this->clientData->metaData, $name);
	}
	public function setMetaData($name, $value) {
		if(_hx_field($this->clientData, "metaData") === null) {
			$this->clientData->metaData = _hx_anonymous(array());
		}
		$this->clientData->metaData->{$name} = $value;
		$this->clientData->update();
	}
	public function getNextMessage() {
		$messageData = org_phpMessaging_model_MessageData::$manager->getNextMessage($this->clientData->id, $this->clientData->applicationId);
		return $messageData;
	}
	public function dispatch($params, $type = null) {
		if($type === null) {
			$type = "";
		}
		$message = new org_phpMessaging_server_Message($this->clientData->id, null, $params, $type);
		$message->send();
	}
	public function wakeUp() {
		$this->clientData->lastActivity = Date::now();
		$this->clientData->update();
	}
	public $clientData;
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
	static function cleanUpIdle($applicationId, $timeOutMs) {
		$listClients = org_phpMessaging_model_ClientData::$manager->cleanUpIdle($timeOutMs);
		if($listClients !== null && $listClients->length > 0) {
			$message = new org_phpMessaging_server_Message(null, $applicationId, $listClients, "TYPE_CLIENT_DELETED");
			$message->send();
		}
	}
	function __toString() { return 'org.phpMessaging.server.Client'; }
}
