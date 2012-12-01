<?php

class org_phpMessaging_server_database_ClientDataManager extends php_db_Manager {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct(_hx_qtype("org.phpMessaging.model.ClientData"));
	}}
	public function getClients($clientIDs = null, $applicationId = null) {
		$query = "";
		if($clientIDs !== null) {
			$id = null;
			{
				$_g = 0;
				while($_g < $clientIDs->length) {
					$id1 = $clientIDs[$_g];
					++$_g;
					if($query !== "") {
						$query .= " OR";
					} else {
						$query .= " (";
					}
					$query .= "id=" . _hx_string_rec($id1, "");
					unset($id1);
				}
			}
			if($query !== "") {
				$query .= ")";
			}
		}
		if($applicationId !== null) {
			if($query !== "") {
				$query .= " AND";
			}
			$query .= "applicationId=" . _hx_string_rec($applicationId, "");
		}
		if($query === "") {
			$query = "1";
		}
		$list = $this->objects($this->select($query), true);
		return $list;
	}
	public function cleanUpIdle($idleMaxMS) {
		$date = Date::fromTime(Date::now()->getTime() - $idleMaxMS);
		$list = $this->objects("SELECT * FROM  " . org_phpMessaging_model_ClientData::$TABLE_NAME . " WHERE  lastActivity <  '" . Std::string($date) . "'", false);
		$clientDataModel = new HList();
		if($list !== null) {
			$clientData = null;
			if(null == $list) throw new HException('null iterable');
			$»it = $list->iterator();
			while($»it->hasNext()) {
				$clientData1 = $»it->next();
				$clientDataModel->push($clientData1->toDataModel());
				$clientData1->delete();
			}
			return $clientDataModel;
		}
		return null;
	}
	public function unmake($clientData) {
		if(_hx_field($clientData, "metaData") !== null) {
			$clientData->metaDataSerialized = haxe_Serializer::run($clientData->metaData);
		}
	}
	public function make($clientData) {
		if($clientData->metaDataSerialized !== null) {
			$clientData->metaData = haxe_Unserializer::run($clientData->metaDataSerialized);
		}
	}
	static $__properties__ = array("set_cnx" => "setConnection");
	function __toString() { return 'org.phpMessaging.server.database.ClientDataManager'; }
}
