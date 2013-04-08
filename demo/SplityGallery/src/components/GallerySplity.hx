package components;

import brix.component.navigation.Page;
import brix.util.DomTools;
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
	//private static var SPLITY_URL:String = "http://demos.silexlabs.org/splity/splity.php/index.php";
	
	private static var ID_IDENT:String = "id";
	
	private static var CHANGE_PAGE:String = "changePage";
	
	private static var CONTEXT_MANAGER_CLASS:String = "ContextManager";
	
	private static var MASTER_BUTTON_ID:String = "master";
	
	private static var MASTER_BUTTON_DOWN_CLASS:String = "down";
	
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
	
	/**
	 * Wether this client can currently control
	 * the gallery
	 */
	private var _isMaster:Bool;
	
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
		_isMaster = false;
		_splityAPI = new SplityAPI();
		_splityAPI.connect(SPLITY_URL, null, null, null);
		_splityAPI.subscribe(onConnect, onError, onStatus);
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
	
	/**
	 * start application
	 */
	function initApplication()
	{
		addFunctionnality(DISPLAY_FUNCTIONNALITY);
		listenToPageChange();
		listenToMasterButton();
        rootElement.addEventListener(TYPE_REQUEST_SEND, cast(onSendMessageRequest), true);
	}
	
	/**
	 * Listen to master button click
	 */
	function listenToMasterButton():Void
	{
		Lib.document.getElementById(MASTER_BUTTON_ID).addEventListener("click", onMasterButtonClick, false);
	}
	
	/**
	 * When the master button is clicked, 
	 * toggle the display of the controls
	 */
	function onMasterButtonClick(e:Event)
	{
		DomTools.toggleClass(e.target, MASTER_BUTTON_DOWN_CLASS);
		
		if (_isMaster == true)
		{
			removeFunctionnality(THUMB_FUNCTIONNALITY);
			removeFunctionnality(REMOTE_FUNCTIONNALITY);
			
			_isMaster = false;
		}
		else
		{
			addFunctionnality(THUMB_FUNCTIONNALITY);
			addFunctionnality(REMOTE_FUNCTIONNALITY);
			_isMaster = true;
		}
	}
	
	function onSendMessageRequest(e:CustomEvent) 
	{
		e.detail.id = _id;
		_splityAPI.dispatch(e.detail, null, null);
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
	 * server, set an id for this client
	 */
	function onConnect()
	{
		_id = "" + Math.round(Math.random() * 1000);
		_splityAPI.setClientMetaData(ID_IDENT, _id, onMetaDataSet, onError);
	}
	
	/**
	 * Once the id of this client is ready,
	 * init the application
	 */
	function onMetaDataSet(data:Dynamic)
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