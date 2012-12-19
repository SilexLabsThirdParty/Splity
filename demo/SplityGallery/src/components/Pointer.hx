package components;

import js.Dom;
import js.Lib;

import brix.component.ui.DisplayObject;
import brix.util.DomTools;
import org.phpMessaging.model.MessageData;

class Pointer extends DisplayObject
{
    private static inline var IMG_SIZE:Int = 5;
    private var _container:HtmlDom;
    private var _imageElement:HtmlDom;
    private var _mouseX:Int = -1000;
    private var _mouseY:Int = -1000;
    private var _timer:haxe.Timer;
	/**
     * Constructor
     */
    public function new(rootElement:HtmlDom, brixId:String) 
    {trace("new Pointer");
        super(rootElement, brixId);
		
        // get the image node
        _imageElement = DomTools.getSingleElement(rootElement, "pointer-image");
		_imageElement.style.position  = "fixed";
		_imageElement.style.zIndex = 30;
		_imageElement.style.top  = "0px";
		_imageElement.style.left = "0px";
        _imageElement.style.display = 'none';
		
        // workaround cocktail issue https://github.com/silexlabs/Cocktail/issues/284
        #if js
        _imageElement.style.zIndex = 1000;
        #else
        _imageElement.style.zIndex = "1000";
        #end
		
        // pointer interactivity
        _container = DomTools.getSingleElement(rootElement, "pages-container");
        _container.addEventListener("mousemove", cast(onMouseMove), true);
        //_container.addEventListener("mousedown", cast(onMouseDown), true);
        _container.addEventListener("mouseup", cast(onMouseUp), true);
        rootElement.addEventListener(MessageData.TYPE_CLIENT_DISPATCH, cast(onDraw), true);
		
		// activate pointer
        var pointerDisplay = DomTools.getSingleElement(rootElement, "pointer-display");
		pointerDisplay.addEventListener("mouseup", cast(displayPointer), true);
		
		// deactivate pointer
        var pointerHide = DomTools.getSingleElement(rootElement, "pointer-hide");
		pointerHide.addEventListener("mouseup", cast(hidePointer), true);
		
    }
	public function displayPointer(e:MouseEvent)
	{
        trace("displayPointer");
		rootElement.style.cursor = "url('assets/pointer-red.png')";		
	}
	public function hidePointer(e:MouseEvent)
	{
        trace("hidePointer");
		rootElement.style.cursor = "";		
	}
    public function onMouseDown(e:MouseEvent) 
    {trace("onMouseDown");
        onMouseMove(e);
        sendDraw();
        if(_timer == null)
            _timer = new haxe.Timer(500);
        _timer.run = sendDraw;
    }
    public function onMouseUp(e:MouseEvent) 
    {trace("onMouseUp");
        if (_timer != null)
        {
            _timer.stop();
//            _timer.run = null;
        }
        _timer = null;
        _imageElement.style.display="none";           
        //_mouseX = -1000;
        //_mouseY = -1000;
        sendDraw();
		draw(_mouseX,_mouseY);
    }
    
    /**
     * Mouse Down callback. Changes the image to be displayed.
     * @param    event
     */
    public function onMouseMove(e:MouseEvent):Void
    {//trace("mouse move "+e.clientX);
        e.preventDefault();
        _mouseX = e.clientX;
        _mouseY = e.clientY;
    }
    public function draw(x:Int, y:Int) 
    {
            _imageElement.style.top = (y-IMG_SIZE)+"px";
            _imageElement.style.left = (x-IMG_SIZE)+"px";
            _imageElement.style.display="inherit";           
    }
    public function sendDraw() 
    {
		var percentX = _mouseX / Lib.window.innerWidth;
		var percentY = _mouseY / Lib.window.innerHeight;
		
        var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
        event.initCustomEvent(GallerySplity.TYPE_REQUEST_SEND, false, false, {
            type: "sendDraw",
            clientX: percentX,
            clientY: percentY,
        });
        rootElement.dispatchEvent(event);
    }
    public function onDraw(e:CustomEvent) 
	{
        if (e.detail.type == "sendDraw")
        {
            var x:Int = Math.round(e.detail.clientX * Lib.window.innerWidth);
            var y:Int = Math.round(e.detail.clientY * Lib.window.innerHeight);
            draw(x, y);
        }
	}
}