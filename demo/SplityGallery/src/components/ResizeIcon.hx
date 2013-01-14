package components;

import js.Lib;
import js.Dom;

import brix.component.ui.DisplayObject;

/**
 * 
 */
class ResizeIcon extends DisplayObject{

	static inline var WIDTH:Int = 25;
	static inline var HEIGHT:Int = 25;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String) {
		super(rootElement, SLPId);
		Lib.window.addEventListener("resize", onResize, false);
		onResize(null);
	}
	public function onResize(e) {

		//trace("ResizeMap - "+rootElement+", "+Lib.document.body.clientWidth+", "+Lib.document.body.clientHeight);
		
		var width:Int = 0;
		var height:Int = 0;
		var marginTop:Int = 0;
		
		//if ((Lib.document.body.clientHeight < 1000) && (Lib.document.body.clientWidth < 2000))
		if((Lib.document.body.clientHeight < 480)&&(Lib.document.body.clientWidth < 640)){
			width = WIDTH;
			height = HEIGHT;
		}
		else {
			width = 2*WIDTH;
			height = 2*HEIGHT;
		}
		
		marginTop = Std.int( -height / 2);
		
		rootElement.style.width = Std.string(width) + "px";
		rootElement.style.height = Std.string(height) + "px";
		rootElement.style.marginTop = Std.string(marginTop) + "px";
	}
}

