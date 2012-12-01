package splity.server;

import org.phpMessaging.server.Application;
import org.phpMessaging.server.ServerConfig;
import org.phpMessaging.server.Server;
import php.io.File;
import php.io.Path;
import php.Sys;

/**
 * this class is an example of use of the php-messaging library
 * it implement the server side of a very simple chat application
 * @author	lexa
 * @link	http://php-polling.sourceforge.net/
 */
class Main
{
	/**
	 * path of the config file, relative to this script
	 */
	static inline var CONFIG_FILE_PATH:String = "../config.php";
	/**
	 * entry point of our application, defined in the .hxml used to compile it
	 */ 
	static function main() 
	{
		// create a remoting context and expose the php-messaging service
		var ctx = new haxe.remoting.Context();
		var server = new Splity(getServerConfig());
		ctx.addObject("Server", server);
		
		//trace(server.getClients());
		
		// handle remoting request
		if( haxe.remoting.HttpConnection.handleRequest(ctx) )
			return;

		// handle normal request
		php.Lib.print("This is a remoting server !");
	}
	/**
	 * load a XML string defined in a .php file as $config, 
	 * not stored in an XML file for seurity reasons
	 */
	static public function getServerConfig():ServerConfig
	{
		// build the absolute path
//		var rootFolderPath:String = Path.directory(Sys.executablePath());
//		var configFilePath:String = rootFolderPath + CONFIG_FILE_PATH;
		var configFilePath:String = CONFIG_FILE_PATH;

		// include the php script
		untyped __call__("include", configFilePath);
				
		// retrieve the xml from the $config global variable defined in the script
		var configString : String = untyped __php__('$config');
		var xml:Xml = Xml.parse(configString);
		
		// parse the XML and store the database settings in a ServerConfig object
		var propXml:Xml;
		var confObj:Dynamic = { };
		for (propXml in xml.firstElement().elementsNamed("db").next().elements())
		{
			if (propXml.firstChild() != null)
			{
				//Log.trace(propXml.nodeName +" = "+propXml.firstChild().nodeValue);
				Reflect.setField(confObj, propXml.nodeName, propXml.firstChild().nodeValue);
			}
		}
		
		// default values
		if (confObj.dbPort == null || confObj.dbPort == "") 
			confObj.dbPort = "3306";
		
		// parse the XML and store the long polling settings in a ServerConfig object
		for (propXml in xml.firstElement().elementsNamed("polling").next().elements())
		{
			if (propXml.firstChild() != null)
			{
				//Log.trace(propXml.nodeName +" = "+propXml.firstChild().nodeValue);
				Reflect.setField(confObj, propXml.nodeName, propXml.firstChild().nodeValue);
			}
		}
		
		// parse the XML and store the timeout settings in a ServerConfig object
		for (propXml in xml.firstElement().elementsNamed("timeout").next().elements())
		{
			if (propXml.firstChild() != null)
			{
				//Log.trace(propXml.nodeName +" = "+propXml.firstChild().nodeValue);
				Reflect.setField(confObj, propXml.nodeName, propXml.firstChild().nodeValue);
			}
		}

		// build the typed config object 
		var config:ServerConfig = 
		{
			dbHost : 					confObj.dbHost,
			dbPassword : 				confObj.dbPassword,
			dbPort : 					Std.parseInt(confObj.dbPort),
			dbUser : 					confObj.dbUser,
			dbName : 					confObj.dbName,
			longPollingDuration : 		Std.parseInt(confObj.longPollingDuration),
			longPollingSleepDuration : 	Std.parseInt(confObj.longPollingSleepDuration),
			clientTimeOut : 			Std.parseInt(confObj.clientTimeOut),
			applicaitonTimeOut : 		Std.parseInt(confObj.applicaitonTimeOut),
			messageTimeOut : 			Std.parseInt(confObj.messageTimeOut)
		};
		
		//Log.trace("Server config loaded " + config);
		return config;
	}
}
