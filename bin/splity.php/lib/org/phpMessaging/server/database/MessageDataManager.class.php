<?php

class org_phpMessaging_server_database_MessageDataManager extends php_db_Manager {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct(_hx_qtype("org.phpMessaging.model.MessageData"));
		if(!php_Session::$started) {
			php_Session::start();
		}
		if(php_Session::get("lastMessageID") !== null) {
			org_phpMessaging_server_database_MessageDataManager::$_lastMessageID = php_Session::get("lastMessageID");
		} else {
			$messageData = $this->object("SELECT * FROM " . org_phpMessaging_model_MessageData::$TABLE_NAME . " ORDER BY id DESC LIMIT 1", true);
			if($messageData !== null) {
				org_phpMessaging_server_database_MessageDataManager::$_lastMessageID = $messageData->id;
			} else {
				org_phpMessaging_server_database_MessageDataManager::$_lastMessageID = -1;
			}
		}
	}}
	public function cleanUpIdle($idleMaxMS) {
		$date = Date::fromTime(Date::now()->getTime() - $idleMaxMS);
		$list = $this->objects("SELECT id FROM  " . org_phpMessaging_model_MessageData::$TABLE_NAME . " WHERE  time <  '" . Std::string($date) . "'", true);
		if($list !== null) {
			$messageData = null;
			if(null == $list) throw new HException('null iterable');
			$»it = $list->iterator();
			while($»it->hasNext()) {
				$messageData1 = $»it->next();
				$messageData1->delete();
			}
			return $list->length;
		}
		return 0;
	}
	public function getNextMessage($clientId, $applicationId) {
		$req = "id>" . _hx_string_rec(org_phpMessaging_server_database_MessageDataManager::$_lastMessageID, "") . " AND (clientId=" . _hx_string_rec($clientId, "") . " OR (applicationId=" . _hx_string_rec($applicationId, "") . " AND clientId IS NULL))";
		$messageData = $this->object($this->select($req), true);
		if($messageData !== null) {
			org_phpMessaging_server_database_MessageDataManager::$_lastMessageID = $messageData->id;
			if(!php_Session::$started) {
				php_Session::start();
			}
			php_Session::set("lastMessageID", org_phpMessaging_server_database_MessageDataManager::$_lastMessageID);
		}
		return $messageData;
	}
	public function unmake($messageData) {
		if(_hx_field($messageData, "metaData") !== null) {
			$messageData->metaDataSerialized = haxe_Serializer::run($messageData->metaData);
		}
	}
	public function make($messageData) {
		if($messageData->metaDataSerialized !== null) {
			$messageData->metaData = haxe_Unserializer::run($messageData->metaDataSerialized);
		}
	}
	static $_lastMessageID;
	static $__properties__ = array("set_cnx" => "setConnection");
	function __toString() { return 'org.phpMessaging.server.database.MessageDataManager'; }
}
