package components;

import js.Dom;
import js.Lib;

import brix.component.ui.DisplayObject;
import brix.util.DomTools;
import org.phpMessaging.model.MessageData;

class Pointer extends DisplayObject
{
    private static inline var IMG_SIZE:Int = 5;
    private var imageElement:HtmlDom;
    private var mouseX:Int = -1000;
    private var mouseY:Int = -1000;
    private var timer:haxe.Timer;
	/**
     * Constructor
     */
    public function new(rootElement:HtmlDom, brixId:String) 
    {trace("new Pointer");
        super(rootElement, brixId);
        // get the image node
        imageElement = DomTools.getSingleElement(rootElement, "pointer-image");
		imageElement.style.position  = "absolute";
		imageElement.style.top  = "0px";
		imageElement.style.left = "0px";
        imageElement.style.display = 'none';
        // workaround cocktail issue https://github.com/silexlabs/Cocktail/issues/284
        #if js
        imageElement.style.zIndex = 1000;
        #else
        imageElement.style.zIndex = "1000";
        #end
        // create interactivity
        var container = DomTools.getSingleElement(rootElement, "pages-container");
        container.style.cursor = 'url(assets/hand.png)';
        container.addEventListener("mousemove", cast(onMouseMove), true);
        container.addEventListener("mousedown", cast(onMouseDown), true);
        container.addEventListener("mouseup", cast(onMouseUp), true);
        rootElement.addEventListener(MessageData.TYPE_CLIENT_DISPATCH, cast(onDraw), true);
    }
    public function onMouseDown(e:MouseEvent) 
    {trace("onMouseDown");
        onMouseMove(e);
        sendDraw();
        if(timer == null)
            timer = new haxe.Timer(500);
        timer.run = sendDraw;
    }
    public function onMouseUp(e:MouseEvent) 
    {trace("onMouseUp");
        if (timer != null)
        {
            timer.stop();
//            timer.run = null;
        }
        timer = null;
        imageElement.style.display="none";           
        mouseX = -1000;
        mouseY = -1000;
        sendDraw();
    }
    
    /**
     * Mouse Down callback. Changes the image to be displayed.
     * @param    event
     */
    public function onMouseMove(e:MouseEvent):Void
    {//trace("mouse move "+e.clientX);
        e.preventDefault();
        mouseX = e.clientX;
        mouseY = e.clientY;
    }
    public function draw(x:Int, y:Int) 
    {
            imageElement.style.top = (y-IMG_SIZE)+"px";
            imageElement.style.left = (x-IMG_SIZE)+"px";
            imageElement.style.display="inherit";           
    }
    public function sendDraw() 
    {
        var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
        event.initCustomEvent(GallerySplity.TYPE_REQUEST_SEND, false, false, {
            type: "sendDraw",
            clientX: mouseX,
            clientY: mouseY,
        });
        rootElement.dispatchEvent(event);
    }
    public function onDraw(e:CustomEvent) 
	{
        if (e.detail.type == "sendDraw")
        {
            var x:Int = e.detail.clientX;
            var y:Int = e.detail.clientY;
            draw(x, y);
        }
	}
}