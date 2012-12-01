<?php

class org_phpMessaging_server_database_ApplicationDataManager extends php_db_Manager {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct(_hx_qtype("org.phpMessaging.model.ApplicationData"));
	}}
	public function cleanUpIdle($idleMaxMS) {
		$date = Date::fromTime(Date::now()->getTime() - $idleMaxMS);
		$list = $this->objects("SELECT id FROM  " . org_phpMessaging_model_ApplicationData::$TABLE_NAME . " WHERE  lastActivity <  '" . Std::string($date) . "'", true);
		if($list !== null) {
			$applicationData = null;
			if(null == $list) throw new HException('null iterable');
			$»it = $list->iterator();
			while($»it->hasNext()) {
				$applicationData1 = $»it->next();
				$applicationData1->delete();
			}
			return $list->length;
		}
		return 0;
	}
	public function unmake($applicationData) {
		if(_hx_field($applicationData, "metaData") !== null) {
			$applicationData->metaDataSerialized = haxe_Serializer::run($applicationData->metaData);
		}
	}
	public function make($applicationData) {
		if($applicationData->metaDataSerialized !== null) {
			$applicationData->metaData = haxe_Unserializer::run($applicationData->metaDataSerialized);
		}
	}
	static $__properties__ = array("set_cnx" => "setConnection");
	function __toString() { return 'org.phpMessaging.server.database.ApplicationDataManager'; }
}
