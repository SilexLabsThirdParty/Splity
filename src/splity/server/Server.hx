/*
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * @author lexa
 */

package ;

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


/**
 * this class is the entry point of the library
 */
class Admin extends Server 
{
	private function checkAuth():Bool
	{
		if (client.getMetaData("pubKey") == "fdsf1435s1fs2q1d" && client.getMetaData("login") == "admin")
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	/**
	 * retrieve the clients data
	 * all clients exposed here, only for debug and monitor purpose
	 */
	public function getAllClients():List<ClientDataModel>
	{
		var listDataModel:List<ClientDataModel>;

		// start the process
		_init();
		
		if (checkAuth())
		{
			// get the data
			var listClients:List<ClientData> = ClientData.manager.getClients();

			// keep only meta data
			listDataModel = listClients.map(function(clientData:ClientData){return clientData.toDataModel();});
		}
		else
		{
			throw ("Admin authorised only "+client.getMetaData("pubKey")+" - "+client.getMetaData("login"));
			listDataModel = new List();
		}
		
		// ends the process
		_cleanup();
		
		if (listDataModel.length == 0){
			throw("Error can not return empy list??");
		}
		return listDataModel;
	}	
	/**
	 * retrieve the clients data
	 * all clients exposed here, only for debug and monitor purpose
	 */
/*
	public function getAllApplications():List<ApplicationData>
	{
		var list:List<ApplicationData>;

		// start the process
		_init();
		
		if (checkAuth())
		{
			// get the data
			list = ApplicationData.manager.objects("SELECT * FROM "+ApplicationData.TABLE_NAME+" WHERE 1", false);
		}
		else
		{
			throw ("Admin authorised only "+client.getMetaData("pubKey")+" - "+client.getMetaData("login"));
			list = new List();
		}
		
		// ends the process
		_cleanup();
		
    	if (list != null)
    	{
	    	// delete each element (workaround "the DELETE query throws an error"
	    	var applicationData:ApplicationData;
	    	for(applicationData in list)
	    		applicationData.metaData = {test:"test"};
	    	
    	}
		if (list.length == 0){
			throw("Error can not return empy list??");
		}
		return list;
	}	
*/
}