<?php

class org_phpMessaging_server_Application {
	public function __construct($name, $instanceName, $serverConfig) {
		if(!php_Boot::$skip_constructor) {
		$this->_serverConfig = $serverConfig;
		org_phpMessaging_model_ApplicationData::$manager->cleanUpIdle($this->_serverConfig->applicaitonTimeOut);
		$this->applicationData = org_phpMessaging_model_ApplicationData::$manager->search(_hx_anonymous(array("name" => $name, "instanceName" => $instanceName)), null)->first();
		if($this->applicationData === null) {
			$this->applicationData = new org_phpMessaging_model_ApplicationData();
			$this->applicationData->name = $name;
			$this->applicationData->instanceName = $instanceName;
			$this->applicationData->time = Date::now();
			$this->applicationData->lastActivity = Date::now();
			$this->applicationData->insert();
		}
		org_phpMessaging_server_Client::cleanUpIdle($this->applicationData->id, $this->_serverConfig->clientTimeOut);
	}}
	public function getMetaData($name) {
		if(_hx_field($this->applicationData, "metaData") === null) {
			return null;
		}
		return Reflect::field($this->applicationData->metaData, $name);
	}
	public function setMetaData($name, $value) {
		if(_hx_field($this->applicationData, "metaData") === null) {
			$this->applicationData->metaData = _hx_anonymous(array());
		}
		$this->applicationData->metaData->{$name} = $value;
		$this->applicationData->update();
	}
	public function dispatch($params, $idClients = null, $type = null) {
		if($type === null) {
			$type = "";
		}
		if($idClients !== null) {
			$idx = null;
			{
				$_g1 = 0; $_g = $idClients->length;
				while($_g1 < $_g) {
					$idx1 = $_g1++;
					$message = new org_phpMessaging_server_Message($idClients[$idx1], null, $params, $type);
					$message->send();
					unset($message,$idx1);
				}
			}
		} else {
			$message = new org_phpMessaging_server_Message(null, $this->applicationData->id, $params, $type);
			$message->send();
		}
	}
	public function wakeUp() {
		$this->applicationData->lastActivity = Date::now();
		$this->applicationData->update();
	}
	public function poll($client) {
		$this->wakeUp();
		org_phpMessaging_model_MessageData::$manager->cleanUpIdle($this->_serverConfig->messageTimeOut);
		$message = null;
		$startTime = Date::now();
		$elapsedTimeMS = null;
		do {
			$client->wakeUp();
			org_phpMessaging_server_Client::cleanUpIdle($this->applicationData->id, $this->_serverConfig->clientTimeOut);
			$messageData = null;
			$messageData = $client->getNextMessage();
			if($messageData !== null) {
				$message = new org_phpMessaging_server_Message(null, null, null, null);
				$message->messageData = $messageData;
			}
			$elapsedTimeMS = Date::now()->getTime() - $startTime->getTime();
			if(php_Session::$started) {
				php_Session::close();
			}
			if($message === null) {
				Sys::sleep($this->_serverConfig->longPollingSleepDuration / 1000);
			}
			if(!php_Session::$started) {
				php_Session::start();
			}
			unset($messageData);
		} while($message === null && $elapsedTimeMS < $this->_serverConfig->longPollingDuration);
		return $message;
	}
	public function accept($clientIp, $params = null) {
		return new org_phpMessaging_server_Client($this->applicationData->id, $params);
	}
	public $_serverConfig;
	public $applicationData;
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
	function __toString() { return 'org.phpMessaging.server.Application'; }
}
