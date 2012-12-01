<?php

class splity_server_Splity extends org_phpMessaging_server_Server {
	public function __construct($serverConfig, $functionalities) { if(!php_Boot::$skip_constructor) {
		parent::__construct($serverConfig);
		splity_server_Splity::$functionalities = $functionalities;
	}}
	public function getFunctionalities() {
		splity_server_Log::trace("getFunctionalities ");
		$clients = $this->getClients(null);
		if(null == $clients) throw new HException('null iterable');
		$»it = $clients->iterator();
		while($»it->hasNext()) {
			$client = $»it->next();
			splity_server_Log::trace("getFunctionalities client " . Std::string($client->metaData->functionalities));
			if(_hx_field($client->metaData, "functionalities") !== null) {
				splity_server_Log::trace("getFunctionalities true");
				{
					$_g = 0; $_g1 = splity_server_Splity::$functionalities;
					while($_g < $_g1->length) {
						$functionality = $_g1[$_g];
						++$_g;
						splity_server_Log::trace("getFunctionalities functionality " . Std::string($functionality));
						if(Lambda::has($client->metaData->functionalities, $functionality->name, null)) {
							$functionality->usage++;
						}
						unset($functionality);
					}
					unset($_g1,$_g);
				}
			}
		}
		splity_server_Log::trace("getFunctionalities end ");
		return splity_server_Splity::$functionalities;
	}
	public function requestFunctionality($functionalityName) {
		$this->_init(null, null, null);
		splity_server_Log::trace("requestFunctionality " . $functionalityName);
		{
			$_g = 0; $_g1 = splity_server_Splity::$functionalities;
			while($_g < $_g1->length) {
				$functionality = $_g1[$_g];
				++$_g;
				if($functionality->name === $functionalityName && $functionality->maxUsage !== null && $functionality->maxUsage <= $functionality->usage) {
					splity_server_Log::trace("requestFunctionality REFUSED " . $functionalityName . " - " . Std::string($functionality));
					$this->_cleanup();
					return false;
				}
				unset($functionality);
			}
		}
		$meta = $this->client->getMetaData("functionalities");
		if($meta === null) {
			$meta = new _hx_array(array());
		}
		$meta->push($functionalityName);
		$this->client->setMetaData("functionalities", $meta);
		splity_server_Log::trace("requestFunctionality " . Std::string($this->client->clientData->metaData));
		$this->_cleanup();
		return true;
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
		splity_server_Log::trace("NEW SERVER " . Std::string($this->client));
	}
	static $functionalities;
	function __toString() { return 'splity.server.Splity'; }
}
splity_server_Splity::$functionalities = new _hx_array(array());
