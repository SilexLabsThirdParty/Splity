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

//import splity.server.functionality.FunctionalityData;
//import splity.server.functionality.FunctionalityDataManager;

class Splity extends Server 
{
	public static var functionalities:Array<FunctionalityData> = [];
	public function new(serverConfig:ServerConfig, functionalities:Array<FunctionalityData>)
	{
		super(serverConfig);
		Splity.functionalities = functionalities;		
	}
	/**
	 * initialize the client and application objects, the database connection, the php session, etc
	 * parameters are optionnal, you can ommit them if they are allready stored in the session, 
	 * i.e. if it is not the 1st connection of this client
	 */
	override private function _init(name:String=null, instanceName:String=null, metaData:Dynamic=null)
	{
		// force instance name to the ip
		//instanceName = Web.getClientIP();
		instanceName = "";
		// fixeme : for tests
		// instanceName = "splity.test1";
		name = "splity";
        var params = php.Web.getParams();
        if(params.exists('app'))
        	name = params.get('app');

		// add info to meta
		if (metaData == null)
			metaData = {};
		metaData.instanceName=instanceName;
		metaData.appName=name;
		
		super._init(name, instanceName, metaData);
		Log.trace("NEW SERVER "+client);
	}
	public function requestFunctionality(functionalityName:String, ?metaData:Dynamic=null):Bool
	{
		var functionalities = getFunctionalities();
		// start the process
		_init();
		Log.trace("requestFunctionality "+functionalityName);
		for (functionality in functionalities)
		{
			if (functionality.name == functionalityName 
				&& functionality.maxUsage != null
				&& functionality.maxUsage <= functionality.usage)
			{	
				Log.trace("requestFunctionality REFUSED "+functionalityName+" - "+functionality);
				_cleanup();
				return false;
			}
		}

		var meta = client.getMetaData("functionalities");
		if (meta == null)
		{
			meta = [];	
		}
		meta.push(functionalityName);
		client.setMetaData("functionalities", meta);
		Log.trace("requestFunctionality "+client.clientData.metaData);

			// dispatch a "new client" message
			var message : Message = new Message(null, application.applicationData.id, metaData, "splity");
			message.send();

		// ends the process
		_cleanup();
		return true;
	}	
	public function getFunctionalities():Array<FunctionalityData>
	{
		Log.trace("getFunctionalities ");
		var clients = getClients();
		for (client in clients)
		{
			Log.trace("getFunctionalities client "+client.metaData.functionalities);
			if (client.metaData.functionalities != null){
				Log.trace("getFunctionalities true");
				for (functionality in functionalities)
				{				
					Log.trace("getFunctionalities functionality "+functionality);
					if (Lambda.has(client.metaData.functionalities, functionality.name))
					{
						functionality.usage++;
					}
				}
			}
		}
		Log.trace("getFunctionalities end ");
		
		return functionalities;
	}	
}