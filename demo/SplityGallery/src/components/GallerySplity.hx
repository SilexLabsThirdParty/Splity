package components;

import brix.component.navigation.Page;
import brix.core.Application;
import js.Dom;
import brix.component.ui.DisplayObject;
import brix.component.navigation.ContextManager;
import js.Lib;
import org.phpMessaging.model.MessageData;
import splity.client.SplityAPI;
import splity.server.FunctionalityData;
 
/**
 * A gallery which can be displayed on multiple
 * devices simultaneously by splitting functionnalities
 */
class GallerySplity extends DisplayObject
{
	//functionnalities ids
	
	private static var THUMB_FUNCTIONNALITY:String = "thumblist";
	
	private static var REMOTE_FUNCTIONNALITY:String = "remote";
	
	private static var DISPLAY_FUNCTIONNALITY:String = "display";
	
	private static var SPLITY_URL:String = "splity.php/index.php";
	
	private static var ID_IDENT:String = "id";
	
	private static var MASTER_ID_IDENT:String = "masterID";
	
	private static var CHANGE_PAGE:String = "changePage";
	
	private static var CONTEXT_MANAGER_CLASS:String = "ContextManager";
	
	public static var TYPE_REQUEST_SEND:String = "RequestSend";
	
	/**
	 * unique id of the client
	 */
	private var _id:String;
	
	/**
	 * instance of SplityAPI communicating
	 * with Splity server
	 */
	private var _splityAPI:SplityAPI;
	
	/**
	 * Wether the last page change was triggered
	 * because of user action (false) or because
	 * of a Splity dispatch (true)
	 */
	private var _remotePageChange:Bool;
	
	public function new(rootElement:HtmlDom, brixId:String) 
	{
		super(rootElement, brixId);
	}
	
	/**
	 * init calls attributes, connect
	 * with Splity server
	 */
	override function init()
	{
		_remotePageChange = false;
		
		_splityAPI = new SplityAPI();
		_splityAPI.connect(SPLITY_URL, null, null, null);
		_splityAPI.subscribe(onConnect, onError, onStatus);
	}
	
	/**
	 * start application
	 */
	function initApplication()
	{
		listenToPageChange();
        rootElement.addEventListener(TYPE_REQUEST_SEND, cast(onSendMessageRequest), true);
	}
	
	function onSendMessageRequest(e:CustomEvent) 
	{
		e.detail.id = _id;
		_splityAPI.dispatch(e.detail, null, null);
	}
	
	//////////////////
	// GALLERY LOGIC
	/////////////////
	
	/**
	 * Called when the current page changed
	 * as a result of a user action,
	 * dispatch with splity to update all
	 * clients
	 */
	function onPageChange(e:Event)
	{
		var ce:CustomEvent = cast(e);
		
		//check that page change is result of user
		//action. If result of another splity
		//dispatch, should not dispatch else 
		//infinite dispatch loop
		if (_remotePageChange == false)
		{
			_splityAPI.dispatch({action:CHANGE_PAGE, pageName:ce.detail.name, id:_id}, null, null);
		}
	}
	
	//////////////////
	// BRIX CALLS
	/////////////////
	
	/**
	 * For this gallery, functionnalities
	 * map to a Brix context, add a new context
	 */
	function addFunctionnality(name)
	{
		getContextManager().addContext(name);
	}
	
	/**
	 * remove the brix context with
	 * the same name as the functionnality
	 */
	function removeFunctionnality(name)
	{
		getContextManager().removeContext(name);
	}
	
	/**
	 * Get an instance of a context manager
	 */
	function getContextManager():ContextManager
	{
		var contextManagerNode = Lib.document.getElementsByClassName(CONTEXT_MANAGER_CLASS)[0];
		var application:Application = Application.get(brixInstanceId);
		
		return application.getAssociatedComponents(contextManagerNode, ContextManager).first();
	}
	
	/**
	 * Called when page must change because
	 * a user on another client changed page
	 */
	function changePage(name)
	{
		_remotePageChange = true;
		var page:Page = Page.getPageByName(name, brixInstanceId);
		page.open(null, null, true, true, true);
	}
	
	/**
	 * Brix page change are listened to on
	 * the html body
	 */
	function listenToPageChange()
	{
		Lib.document.body.addEventListener(Page.EVENT_TYPE_OPEN_START, onPageChange, false);
		Lib.document.body.addEventListener(Page.EVENT_TYPE_OPEN_STOP, onTransitionEnd, false);
	}
	
	/**
	 * on transition end, set dirty flag to false
	 */
	function onTransitionEnd(e:Event)
	{
		_remotePageChange = false;
	}
	
	//////////////////
	// SPLITY CALLBACKS
	/////////////////
	
	/**
	 * When successfully connected with Splity
	 * server, retrieve client id
	 */
	function onConnect()
	{
		_splityAPI.getClientMetaData(ID_IDENT, onIDMetaDataReceived, onError);
	}
	
	/**
	 * If id is null, this is
	 * the first time this client connects
	 * to the application, create and regisyter an id for
	 * it, else use the already existing one
	 */
	function onIDMetaDataReceived(id:String)
	{
		if (id == null)
		{
			_id = "" + Math.round(Math.random() * 1000);
			_splityAPI.setClientMetaData(ID_IDENT, _id, onMetaDataSet, onError);
		}
		else
		{
			_id = id;
			onMetaDataSet(null);
		}
	}
	
	/**
	 * Once the id of this client is ready,
	 * retrieve the id of the client which 
	 * must have the navigation functionnality,
	 * stored in the application metadata
	 */
	function onMetaDataSet(data:Dynamic)
	{
		_splityAPI.getApplicationMetaData(MASTER_ID_IDENT, onMasterIDReceived, onError);
	}
	
	/**
	 * Called once the id forthe client which
	 * should have the navigation functionnalities
	 * has been retrieved
	 */
	function onMasterIDReceived(id:String)
	{
		//if id not set yet, then this client is
		//the first to connect and becomes the master
		//client, store its id as the master id
		if (id == null)
		{
			addFunctionnality(THUMB_FUNCTIONNALITY);
			addFunctionnality(REMOTE_FUNCTIONNALITY);
			addFunctionnality(DISPLAY_FUNCTIONNALITY);
			_splityAPI.setApplicationMetaData(MASTER_ID_IDENT, _id, onMasterIDSet, onError);
		}
		//else if master id is this client's id, 
		//then show all the navigation UI
		else if (id == _id)
		{
			addFunctionnality(THUMB_FUNCTIONNALITY);
			addFunctionnality(REMOTE_FUNCTIONNALITY);
			addFunctionnality(DISPLAY_FUNCTIONNALITY);
			initApplication();
		}
		//else hide the navigation UI
		else
		{
			addFunctionnality(DISPLAY_FUNCTIONNALITY);
			removeFunctionnality(THUMB_FUNCTIONNALITY);
			removeFunctionnality(REMOTE_FUNCTIONNALITY);
			initApplication();
		}
	}
	
	/**
	 * Called when the id of this client as
	 * been successfuly set as the master id
	 */
	function onMasterIDSet(data:Dynamic)
	{
		initApplication();
	}
	
	/**
	 * Called every time there
	 * is an error with the splity
	 * server
	 */
	function onError(str:String)
	{
		trace(str);
	}

	/**
	 * Called when there is an update from
	 * the Splity server
	 */
	function onStatus(messageData:MessageDataModel)
	{
		switch (messageData.type)
		{
			case MessageData.TYPE_CLIENT_DISPATCH:
				if (messageData.metaData.id != _id)
				{
					if (messageData.metaData.action == CHANGE_PAGE)
					{
							changePage(messageData.metaData.pageName);
					}
					else
					{
				        var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
				        event.initCustomEvent(MessageData.TYPE_CLIENT_DISPATCH, false, false, messageData.metaData);
				        rootElement.dispatchEvent(event);
					}
				}
		}
	}
}