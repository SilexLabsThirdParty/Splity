package components;

import brix.component.navigation.Page;
import brix.core.Application;
import js.Dom;
import brix.component.ui.DisplayObject;
import brix.component.navigation.ContextManager;
import js.Lib;
import org.phpMessaging.model.MessageData;
import splity.client.SplityAPI;


/**
 * The display modes of the galery
 */
enum GalleryMode {
	DESKTOP;
	TABLET;
	PHONE;
}
 
/**
 * A gallery which can be displayed on multiple
 * devices simultaneously by splitting functionnalities
 */
class GallerySplity extends DisplayObject
{
	//functionnalities ids
	
	private static var THUMB_FUNCTIONNALITY:String = "thumb";
	
	private static var REMOTE_FUNCTIONNALITY:String = "remote";
	
	private static var DISPLAY_FUNCTIONNALITY:String = "display";
	
	private static var SPLITY_URL:String = "http://169.254.240.203:8888/Splity/www/";
	
	private static var ID_IDENT:String = "id";
	
	private static var CHANGE_PAGE:String = "changePage";
	
	private static var CONTEXT_MANAGER_ID:String = "contextManager";
	
	/**
	 * unique id of the client
	 */
	private var _id:String;
	
	/**
	 * current mode of gallery
	 */
	private var _mode:GalleryMode;
	
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
		_id = "" + Math.round(Math.random() * 1000);
		_remotePageChange = false;
		initMode();
		
		_splityAPI = new SplityAPI();
		_splityAPI.connect(SPLITY_URL, null, null, null);
		_splityAPI.subscribe(onConnect, onError, onStatus);
		
	}
	
	/**
	 * Determine the mode the
	 * gallery should use based on device
	 */
	function initMode()
	{
		if (Lib.window.innerWidth > 1280)
		{
			_mode = DESKTOP;
		}
		else if ( Lib.window.innerWidth < 1280 && Lib.window.innerWidth > 780)
		{
			_mode = TABLET;
		}
		else
		{
			_mode = PHONE;
		}
	}
	
	/**
	 * start application
	 */
	function initApplication()
	{
		refreshFunctionnalities();
		listenToPageChange();
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
			_splityAPI.dispatch({action:CHANGE_PAGE, pageName:ce.detail.page.name}, null, null);
		}
		
		_remotePageChange = false;
	}
	
	/**
	 * fetch the current list of functionalities
	 * and data on their usage
	 */
	function refreshFunctionnalities()
	{
		_splityAPI.getFunctionalities(onFunctionnalities, onError);
	}
	
	/**
	 * Called once the list of functionnalities
	 * data has ben loaded
	 */
	function onFunctionnalities(functionnalities:List<Dynamic>)
	{
		switch (_mode)
		{
			case DESKTOP:
				setDesktopFunctionnalities(functionnalities);
				
			case TABLET:
				setTabletFunctionnalities(functionnalities);
				
			case PHONE:
				setPhoneFunctionnalities(functionnalities);
		}
	}
	
	/**
	 * In desktop mode, the gallery displays
	 * all functionnalities which are not
	 * displayed by another devices
	 */
	function setDesktopFunctionnalities(functionnalities:List<Dynamic>)
	{
		for (functionnality in functionnalities)
		{
			if (functionnality.maxUsage == null)
			{
				addFunctionnality(functionnality.name);
			}
			else if (functionnality.usage < functionnality.maxUsage)
			{
				addFunctionnality(functionnality.name);
			}
			else
			{
				removeFunctionnality(functionnality.name);
			}
		}
	}
	
	/**
	 * In tablet mode, request the exclusive display
	 * of the thumb list
	 */
	function setTabletFunctionnalities(functionnalities:List<Dynamic>)
	{
		_splityAPI.requestFunctionnality(THUMB_FUNCTIONNALITY, onTabletFunctionnality, onError);
	}
	
	/**
	 * Called when a tablet client receives exclusive
	 * display of thumb functionnality
	 */
	function onTabletFunctionnality()
	{
		removeFunctionnality(REMOTE_FUNCTIONNALITY);
		addFunctionnality(DISPLAY_FUNCTIONNALITY);
		addFunctionnality(THUMB_FUNCTIONNALITY);
	}
	
	/**
	 * In phone mode, request the exclusive display
	 * of the remote
	 */
	function setPhoneFunctionnalities(functionnalities:List<Dynamic>)
	{
		_splityAPI.requestFunctionnality(REMOTE_FUNCTIONNALITY, onPhoneFunctionnality, onError);
	}
	
	/**
	 * Called when a phone client receives exclusive
	 * display of remote functionnality
	 */
	function onPhoneFunctionnality()
	{
		removeFunctionnality(THUMB_FUNCTIONNALITY);
		addFunctionnality(REMOTE_FUNCTIONNALITY);
		addFunctionnality(DISPLAY_FUNCTIONNALITY);
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
		getContextManger().addContext(name);
	}
	
	/**
	 * remove the brix context with
	 * the same name as the functionnality
	 */
	function removeFunctionnality(name)
	{
		getContextManger().removeContext(name);
	}
	
	function getContextManger():ContextManager
	{
		var contextManagerNode = Lib.document.getElementById(CONTEXT_MANAGER_ID);
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
		Page.openPage(name, false, null, null, null);
	}
	
	/**
	 * Brix page change are listened to on
	 * the html body
	 */
	function listenToPageChange()
	{
		Lib.document.body.addEventListener(Page.EVENT_TYPE_OPEN_START, onPageChange, false);
	}
	
	//////////////////
	// SPLITY CALLBACKS
	/////////////////
	
	/**
	 * When successfully connected with Splity
	 * server, register a unique id for this
	 * client
	 */
	function onConnect()
	{
		_splityAPI.setClientMetaData(ID_IDENT, _id, onMetaDataSet, onError);
	}
	
	/**
	 * Once the id is registered, start
	 * the application
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
			case SplityAPI.SPLITY:
				if (_mode == DESKTOP)
				{
					refreshFunctionnalities();
				}
				
			case MessageData.TYPE_CLIENT_DELETED:
				if (_mode == DESKTOP)
				{
					refreshFunctionnalities();
				}
				
			case MessageData.TYPE_CLIENT_DISPATCH:
				if (messageData.metaData.action == CHANGE_PAGE)
				{
					changePage(messageData.metaData.pageName);
				}
		}
	}
}