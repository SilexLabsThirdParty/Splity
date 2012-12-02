package splity.client;

/**
 * ...
 * @author 
 */

class SplityAPI extends org.phpMessaging.client.Connection
{

	public static var SPLITY:String = "splity";
	
	public function new() 
	{
		super();
	}
	 
	public function getFunctionalities(onSuccess, onError)
	{
		var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(_serverUrl);
	    cnx.setErrorHandler( onError );
	    cnx.Server.getFunctionalities.call([], onSuccess);
	}
	
	public function requestFunctionnality(name, onSuccess, onError)
	{
		var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(_serverUrl);
	    cnx.setErrorHandler( onError );
	    cnx.Server.requestFunctionality.call([name], onSuccess);
	}
}