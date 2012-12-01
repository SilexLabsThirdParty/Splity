<?php

class splity_server_Main {
	public function __construct(){}
	static $CONFIG_FILE_PATH = "../config.php";
	static function main() {
		include("../config.php");
		$configString = $config;
		$xml = Xml::parse($configString);
		$ctx = new haxe_remoting_Context();
		$server = new splity_server_Splity(splity_server_Main::getServerConfig($xml), splity_server_Main::getFunctionalities($xml));
		$ctx->addObject("Server", $server, null);
		if(haxe_remoting_HttpConnection::handleRequest($ctx)) {
			return;
		}
		php_Lib::hprint("This is a remoting server !");
	}
	static function getServerConfig($xml) {
		$propXml = null;
		$confObj = _hx_anonymous(array());
		if(null == $xml->firstElement()->elementsNamed("db")->next()) throw new HException('null iterable');
		$»it = $xml->firstElement()->elementsNamed("db")->next()->elements();
		while($»it->hasNext()) {
			$propXml1 = $»it->next();
			if($propXml1->firstChild() !== null) {
				$confObj->{$propXml1->getNodeName()} = $propXml1->firstChild()->getNodeValue();
			}
		}
		if(_hx_field($confObj, "dbPort") === null || _hx_equal($confObj->dbPort, "")) {
			$confObj->dbPort = "3306";
		}
		if(null == $xml->firstElement()->elementsNamed("polling")->next()) throw new HException('null iterable');
		$»it = $xml->firstElement()->elementsNamed("polling")->next()->elements();
		while($»it->hasNext()) {
			$propXml1 = $»it->next();
			if($propXml1->firstChild() !== null) {
				$confObj->{$propXml1->getNodeName()} = $propXml1->firstChild()->getNodeValue();
			}
		}
		if(null == $xml->firstElement()->elementsNamed("timeout")->next()) throw new HException('null iterable');
		$»it = $xml->firstElement()->elementsNamed("timeout")->next()->elements();
		while($»it->hasNext()) {
			$propXml1 = $»it->next();
			if($propXml1->firstChild() !== null) {
				$confObj->{$propXml1->getNodeName()} = $propXml1->firstChild()->getNodeValue();
			}
		}
		$config = _hx_anonymous(array("dbHost" => $confObj->dbHost, "dbPassword" => $confObj->dbPassword, "dbPort" => Std::parseInt($confObj->dbPort), "dbUser" => $confObj->dbUser, "dbName" => $confObj->dbName, "longPollingDuration" => Std::parseInt($confObj->longPollingDuration), "longPollingSleepDuration" => Std::parseInt($confObj->longPollingSleepDuration), "clientTimeOut" => Std::parseInt($confObj->clientTimeOut), "applicaitonTimeOut" => Std::parseInt($confObj->applicaitonTimeOut), "messageTimeOut" => Std::parseInt($confObj->messageTimeOut)));
		return $config;
	}
	static function getFunctionalities($xml) {
		$functionalities = new _hx_array(array());
		if(null == $xml->firstElement()->elementsNamed("splity")->next()) throw new HException('null iterable');
		$»it = $xml->firstElement()->elementsNamed("splity")->next()->elements();
		while($»it->hasNext()) {
			$propXml = $»it->next();
			if(null == $propXml) throw new HException('null iterable');
			$»it2 = $propXml->elements();
			while($»it2->hasNext()) {
				$functionalityXml = $»it2->next();
				$functionnality = _hx_anonymous(array("name" => "", "maxUsage" => null, "usage" => 0));
				if(null == $functionalityXml) throw new HException('null iterable');
				$»it3 = $functionalityXml->elements();
				while($»it3->hasNext()) {
					$propertyXml = $»it3->next();
					if($propertyXml->getNodeName() === "name") {
						$functionnality->name = $propertyXml->firstChild()->getNodeValue();
					} else {
						if($propertyXml->getNodeName() === "maxUsage") {
							$functionnality->maxUsage = Std::parseInt($propertyXml->firstChild()->getNodeValue());
						}
					}
				}
				$functionalities->push($functionnality);
				unset($functionnality);
			}
		}
		return $functionalities;
	}
	function __toString() { return 'splity.server.Main'; }
}
