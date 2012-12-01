
package splity.server;

import org.phpMessaging.server.Server;
import org.phpMessaging.server.Application;
import org.phpMessaging.server.Client;
import org.phpMessaging.server.Message;
import org.phpMessaging.server.database.DatabaseConnection;
import org.phpMessaging.server.ServerConfig;
import org.phpMessaging.model.MessageData;
import org.phpMessaging.model.ClientData;
import org.phpMessaging.model.ApplicationData;

import php.Lib;
import php.Web;
import php.Session;


class Splity extends Server 
{
	/**
	 * initialize the client and application objects, the database connection, the php session, etc
	 * parameters are optionnal, you can ommit them if they are allready stored in the session, 
	 * i.e. if it is not the 1st connection of this client
	 */
	override private function _init(name:String=null, instanceName:String=null, metaData:Dynamic=null)
	{
		// force instance name to the ip
		instanceName = Web.getClientIP();
		// fixeme : for tests
		instanceName = "splity.test1";
		name = "splity";
		// add info to meta
		if (metaData == null)
			metaData = {};
		metaData.instanceName=instanceName;
		metaData.appName=name;
		
		super._init(name, instanceName, metaData);
	}
	/**
	 * retrieve the clients data
	 * all clients exposed here, only for debug and monitor purpose
	 */
	public function getAllClients(clientIDs:Array<Int> = null, applicationId:Int = null):List<ClientDataModel>
	{
		// start the process
		_init();
		
		// get the data
		var listClients:List<ClientData> = ClientData.manager.getClients(clientIDs, applicationId);

		// keep only meta data
		var listDataModel:List<ClientDataModel> = listClients.map(function(clientData:ClientData){return clientData.toDataModel();});
		
		// ends the process
		_cleanup();
		
		if (listDataModel.length == 0){
			throw("Error can not return empy list??");
		}
		return listDataModel;
	}	
}