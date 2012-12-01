/*
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package ;

import org.phpMessaging.client.Connection;
import org.phpMessaging.model.ClientData;
import org.phpMessaging.model.MessageData;
import org.phpMessaging.model.ApplicationData;
import js.Lib;
import js.Dom;

/**
 * this class is an example of use of the php-messaging library
 * it implement the client side of a very simple chat application
 * @author	lexa
 * @link	http://php-polling.sourceforge.net/
 */
class MainJs
{
	/**
	 * the connection object, used to interact with the server
	 * this is the main class of the php messaging library which we use client side
	 */
	private var connection:Connection;
	var template:String;
	//var templateApps:String;
	/**
	 * entry point of our application, defined in the .hxml used to compile it
	 * create and store a MainJS instance
	 */
	static function main() 
	{ 
		new MainJs();
	}
	/**
	 * constructor of the MainJS class
	 * load the config
	 */
	public function new()
	{
		cast(Lib.window).addEventListener("load", function (e:Event) 
		{trace("onload");
			haxe.Timer.delay(init, 500);
		}, true);
	}
	var myId:String;
	var messageDiv:HtmlDom;
	function init()
	{
		var lang = untyped navigator.language;
		myId = ""+Math.round(Math.random()*1000);
		// opens the connection with the messaging server
		connection = new Connection();
		connection.connect("server.php/", "admin", "admin", { login: "admin", pubKey: "fdsf1435s1fs2q1d" } );
		// start listening for the server notifications, 
		// with _onStatus as a callback to handle these notifications
		connection.subscribe(onConnect, onError, onStatus);

		messageDiv = Lib.document.getElementById("message");
		// init ui
		Lib.document.getElementById("dispatch").onclick = dispatch;
		Lib.document.getElementById("refresh").onclick = refreshCallback;
		template = Lib.document.getElementById("template").innerHTML;
		Lib.document.getElementById("template").innerHTML = "";
		//templateApps = Lib.document.getElementById("template-apps").innerHTML;
		//Lib.document.getElementById("template-apps").innerHTML = "";
	}
	function onError(str:Dynamic)
	{
		trace("error: "+str);
		//Lib.alert("error: "+str);
		//init();
	}
	/**
	 * callback called one time, after the connection succeeded
	 * it asks the server for the list of all the clients connected to the same application instance 
	 */
	private function onConnect():Void
	{ 
		trace("onConnect ");
		connection.setClientMetaData("myId", myId, function (d:Dynamic) 
		{trace("setClientMetaData "+myId+" - "+d);
			refresh();	
		}, onError);
	}
	private function refreshCallback(e:Event){
		refresh();
	}
	private function refresh(){
		pollClients();
	}
	private function dispatch(e:Event) 
	{
		//trace("dispatch ");
		connection.dispatch("I'm here! Number "+myId, null, function() { trace("dispatch result"); } );
	}
	private function pollClients() 
	{
	    var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(connection._serverUrl);
	    cnx.setErrorHandler( onError );
	    cnx.Server.getAllClients.call([], onGetClients);
	}
	function onGetClients(list:List<ClientDataModel>) 
	{
		trace("onGetClients "+list.length);

        var t = new haxe.Template(template);
        var output = t.execute({ count : list.length, clients : list , myId : myId});
		Lib.document.getElementById("template").innerHTML = output;

		//pollApplications();
	}
/*	private function pollApplications() 
	{
	    var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(connection._serverUrl);
	    cnx.setErrorHandler( onError );
	    cnx.Server.getAllApplications.call([], onGetApplication);
	}
*/
/*	function onGetApplication(list:List<ApplicationData>) 
	{
		trace("onGetApplication "+list.length);

        var t = new haxe.Template(templateApps);
        var output = t.execute({ count : list.length, apps : list , myId : myId});
		Lib.document.getElementById("template-apps").innerHTML = output;
	}
*/	function showMessage(str) 
	{trace("showMessage "+str);
		// to update info (activity)
		pollClients();
		messageDiv.innerHTML = ""+str;
	}
	/**
	 * callback to handle the server notifications
	 */
	private function onStatus(messageData: MessageDataModel):Void
	{ 
		trace("onStatus "+messageData);
		// check if this is a notification of a new client or a "new client" message
		if (messageData.type == MessageData.TYPE_CLIENT_CREATED)
		{
			showMessage("New user");
		}
		// check if this is a notification of a new client or a "client left" message
		else if (messageData.type == MessageData.TYPE_CLIENT_DELETED)
		{
			showMessage("User left ");
		}
		// or is this a message sent by another clients connected to the same application instance 
		else if(messageData.type == MessageData.TYPE_CLIENT_DISPATCH)
		{
			showMessage("User message: "+messageData.metaData);
		}
	}
}
