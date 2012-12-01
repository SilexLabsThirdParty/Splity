package components;

import js.Dom;
import brix.component.ui.DisplayObject;


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
	
	private static var SPLITY_URL:String = "Fake.php";
	
	private static var ID_IDENT:String = "id";
	
	private static var CHANGE_PAGE:String = "changePage";
	
	private var _id:String;
	
	private var _mode:GalleryMode;
	
	private var _splityAPI:SplityAPI;
	
	private var _remotePageChange:Bool;
	
	public function new(rootElement:HtmlDom, brixId:String) 
	{
		init();
	}
	
	/**
	 * init calls attributes, connect
	 * with Splity server
	 */
	function init()
	{
		_id = "" + Math.round(Math.random() * 1000);
		_remotePageChange = false;
		
		_splityAPI = new SplityAPI();
		_splityAPI.connect(SPLITY_URL);
		_splityAPI.subscribe(onConnect, onError, onStatus);
		
		initMode();
	}
	
	/**
	 * Determine the mode the
	 * gallery should use based on device
	 */
	function initMode()
	{
		//TODO : init client mode, based on viewport size ?
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
	function onPageChange()
	{
		if (_remotePageChange == false)
		{
			_splityAPI.dispatch(CHANGE_PAGE);
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
	function onFunctionnalities(functionnalities)
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
	function setDesktopFunctionnalities(functionnalities)
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
	function setTabletFunctionnalities(functionnalities)
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
	function setPhoneFunctionnalities(functionnalities)
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
		ContextManager.addContext(name);
	}
	
	/**
	 * remove the brix context with
	 * the same name as the functionnality
	 */
	function removeFunctionnality(name)
	{
		ContextManager.removeContext(name);
	}
	
	/**
	 * Called when page must change because
	 * a user on another client changed page
	 */
	function changePage(name)
	{
		Page.openPage(name);
	}
	
	/**
	 * Brix page change are listened to on
	 * the html body
	 */
	function listenToPageChange()
	{
		Lib.document.body.addEventListener("pageChange", onPageChange);
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
	function onMetaDataSet()
	{
		initAppliation();
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
			case MessageDataModel.SPLITY:
				if (_mode == DESKTOP)
				{
					refreshFunctionnalities();
				}
				
			case MessageDataModel.TYPE_CLIENT_DELETED:
				if (_mode == DESKTOP)
				{
					refreshFunctionnalities();
				}
				
			case MessageDataModel.TYPE_CLIENT_DISPATCH:
				if (messageData.name == CHANGE_PAGE)
				{
					changePage(messageData.pageName);
				}
		}
	}
}