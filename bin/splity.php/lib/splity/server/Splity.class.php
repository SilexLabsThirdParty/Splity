<?php

class splity_server_Splity extends org_phpMessaging_server_Server {
	public function __construct($serverConfig) { if(!php_Boot::$skip_constructor) {
		parent::__construct($serverConfig);
	}}
	public function getAllClients($clientIDs = null, $applicationId = null) {
		$this->_init(null, null, null);
		$listClients = org_phpMessaging_model_ClientData::$manager->getClients($clientIDs, $applicationId);
		$listDataModel = $listClients->map(array(new _hx_lambda(array(&$applicationId, &$clientIDs, &$listClients), "splity_server_Splity_0"), 'execute'));
		$this->_cleanup();
		if($listDataModel->length === 0) {
			throw new HException("Error can not return empy list??");
		}
		return $listDataModel;
	}
	public function _init($name = null, $instanceName = null, $metaData = null) {
		$instanceName = $_SERVER['REMOTE_ADDR'];
		$instanceName = "splity.test1";
		$name = "splity";
		if($metaData === null) {
			$metaData = _hx_anonymous(array());
		}
		$metaData->instanceName = $instanceName;
		$metaData->appName = $name;
		parent::_init($name,$instanceName,$metaData);
	}
	function __toString() { return 'splity.server.Splity'; }
}
function splity_server_Splity_0(&$applicationId, &$clientIDs, &$listClients, $clientData) {
	{
		return $clientData->toDataModel();
	}
}
