package components;

import js.Dom;
import js.Lib;

class Pointer
{
	static var pointer:Image;
	/**
     * Constructor
     */
    public function new()
    {
        // get the image node
        pointer = cast Lib.document.createElement("img");
		pointer.src = 'assets/hand.png';
		pointer.style.position  = "absolute";
		pointer.style.top  = "0px";
		pointer.style.left = "0px";
		pointer.style.display = 'none';
		Lib.document.body.appendChild(pointer);
        // create interactivity
        Lib.document.getElementsByClassName("pages-container")[0].onmousemove = onMouseMove;        
    }
    
    /**
     * Mouse Down callback. Changes the image to be displayed.
     * @param    event
     */
    public static function onMouseMove(event:Event):Void
    {
        draw(event.clientX, event.clientY);
    }
    public static function draw(x:Float, y:Float) 
	{		
		pointer.style.top = y+"px";
		pointer.style.left = x+"px";
		pointer.style.display="inherit";			
	}
    
}