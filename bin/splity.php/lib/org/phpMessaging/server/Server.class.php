<?php

class org_phpMessaging_server_Server {
	public function __construct($serverConfig) {
		if(!php_Boot::$skip_constructor) {
		$this->_serverConfig = $serverConfig;
	}}
	public function getClients($clientIDs = null) {
		$this->_init(null, null, null);
		$listClients = org_phpMessaging_model_ClientData::$manager->getClients($clientIDs, $this->application->applicationData->id);
		$listDataModel = $listClients->map(array(new _hx_lambda(array(&$clientIDs, &$listClients), "org_phpMessaging_server_Server_0"), 'execute'));
		$this->_cleanup();
		if($listDataModel->length === 0) {
			throw new HException("Error can not return empy list??");
		}
		return $listDataModel;
	}
	public function getApplicationMetaData($name) {
		$this->_init(null, null, null);
		$metaData = $this->application->getMetaData($name);
		$this->_cleanup();
		return $metaData;
	}
	public function setApplicationMetaData($name, $value) {
		$this->_init(null, null, null);
		$this->application->setMetaData($name, $value);
		$this->_cleanup();
	}
	public function getClientMetaData($name) {
		$this->_init(null, null, null);
		$metaData = $this->client->getMetaData($name);
		$this->_cleanup();
		return $metaData;
	}
	public function setClientMetaData($name, $value) {
		$this->_init(null, null, null);
		$this->client->setMetaData($name, $value);
		$this->_cleanup();
	}
	public function dispatch($params, $idClients = null, $type = null) {
		if($type === null) {
			$type = "";
		}
		$this->_init(null, null, null);
		$this->application->dispatch($params, $idClients, $type);
		$this->_cleanup();
	}
	public function poll($name = null, $instanceName = null, $metaData = null) {
		$this->_init($name, $instanceName, $metaData);
		$message = $this->application->poll($this->client);
		$this->_cleanup();
		if($message !== null) {
			return $message->messageData->toDataModel();
		} else {
			return null;
		}
	}
	public function unsubscribe() {
		$this->_init(null, null, null);
		$this->client->clientData->lastActivity = new Date(0, 0, 0, 0, 0, 0);
		$this->client->clientData->update();
		org_phpMessaging_server_Client::cleanUpIdle($this->application->applicationData->id, $this->application->serverConfig->clientTimeOut);
		$this->_cleanup();
	}
	public function _cleanup() {
		org_phpMessaging_server_database_DatabaseConnection::close();
		if(php_Session::$started) {
			php_Session::close();
		}
	}
	public function _init($name = null, $instanceName = null, $metaData = null) {
		if(!php_Session::$started) {
			php_Session::start();
		}
		if($name === null) {
			$name = php_Session::get("applicationName");
		} else {
			php_Session::set("applicationName", $name);
		}
		if($instanceName === null) {
			$instanceName = php_Session::get("instanceName");
		} else {
			php_Session::set("instanceName", $instanceName);
		}
		org_phpMessaging_server_database_DatabaseConnection::open($this->_serverConfig->dbHost, $this->_serverConfig->dbPort, $this->_serverConfig->dbName, $this->_serverConfig->dbUser, $this->_serverConfig->dbPassword, null);
		$this->application = new org_phpMessaging_server_Application($name, $instanceName, $this->_serverConfig);
		$this->client = $this->application->accept($_SERVER['REMOTE_ADDR'], $metaData);
	}
	public $_serverConfig;
	public $client;
	public $application;
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
	function __toString() { return 'org.phpMessaging.server.Server'; }
}
function org_phpMessaging_server_Server_0(&$clientIDs, &$listClients, $clientData) {
	{
		return $clientData->toDataModel();
	}
}
