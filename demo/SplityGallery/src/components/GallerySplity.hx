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
	
	private static var THUMB_FUNCTIONNALITY:String = "thumblist";
	
	private static var REMOTE_FUNCTIONNALITY:String = "remote";
	
	private static var DISPLAY_FUNCTIONNALITY:String = "display";
	
	private static var SPLITY_URL:String = "splity.php/index.php";
	//private static var SPLITY_URL:String = "http://demos.silexlabs.org/splity/splity.php/index.php";
	
	private static var ID_IDENT:String = "id";
	
	private static var CHANGE_PAGE:String = "changePage";
	
	private static var CONTEXT_MANAGER_CLASS:String = "ContextManager";
	
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
		else if (Lib.window.innerWidth < 1280 && Lib.window.innerWidth > 780)
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
		listenToApplicationClose();
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
	function onFunctionnalities(functionnalities:Array<FunctionalityData>)
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
	function setDesktopFunctionnalities(functionnalities:Array<FunctionalityData>)
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
	function setTabletFunctionnalities(functionnalities:Array<FunctionalityData>)
	{
		_splityAPI.requestFunctionnality(THUMB_FUNCTIONNALITY, onTabletFunctionnality, onError, {id:_id});
	}
	
	/**
	 * Called when a tablet client receives exclusive
	 * display of thumb functionnality
	 */
	function onTabletFunctionnality(granted:Bool)
	{
		if (granted == true)
		{
			removeFunctionnality(REMOTE_FUNCTIONNALITY);
			addFunctionnality(DISPLAY_FUNCTIONNALITY);
			addFunctionnality(THUMB_FUNCTIONNALITY);
		}
		else
		{
			onFunctionnalityDenied();
		}
		
	}
	
	/**
	 * In phone mode, request the exclusive display
	 * of the remote
	 */
	function setPhoneFunctionnalities(functionnalities:Array<FunctionalityData>)
	{
		_splityAPI.requestFunctionnality(REMOTE_FUNCTIONNALITY, onPhoneFunctionnality, onError, {id:_id});
	}
	
	/**
	 * Called when a phone client receives exclusive
	 * display of remote functionnality
	 */
	function onPhoneFunctionnality(granted:Bool)
	{
		if (granted == true)
		{
			removeFunctionnality(THUMB_FUNCTIONNALITY);
			addFunctionnality(REMOTE_FUNCTIONNALITY);
			addFunctionnality(DISPLAY_FUNCTIONNALITY);
		}
		//here request was denied
		else
		{
			onFunctionnalityDenied();
		}
	}
	
	/**
	 * When a functionnality request is denied,
	 * default to only showing the display
	 */
	function onFunctionnalityDenied()
	{
		removeFunctionnality(REMOTE_FUNCTIONNALITY);
		removeFunctionnality(THUMB_FUNCTIONNALITY);
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
	 * Listen to web page close
	 */
	function listenToApplicationClose()
	{
		Lib.window.addEventListener("unload", onClose, false);
	}
	
	/**
	 * Signal to Splity that connection
	 * should end
	 */
	function onClose(e:Event)
	{
		Lib.document.body.removeEventListener(Page.EVENT_TYPE_OPEN_START, onPageChange, false);
		Lib.document.body.removeEventListener(Page.EVENT_TYPE_OPEN_STOP, onTransitionEnd, false);
		Lib.window.removeEventListener("unload", onClose, false);
		
		_splityAPI.unsubscribe();
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
		trace(messageData);
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
					if (messageData.metaData.id != _id)
					{
						changePage(messageData.metaData.pageName);
					}
				}
		}
	}
}