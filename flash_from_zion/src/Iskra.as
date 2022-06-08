package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author myachin
	 */
	public class Iskra extends Sprite
	{
		
		public function Iskra(_x:Number, _y:Number, async:Boolean = false) 
		{
			x = _x;
			y = _y;
			if (async) frames = -2;
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			onFrame();
		}
		
		private var frames:int = -1;
		
		public function onFrame(e:Event = null):void
		{
			graphics.clear();
			
			frames++;
			if (frames == 2)
			{
				removeEventListener(Event.ENTER_FRAME, onFrame);
				parent.removeChild(this);
			}
			
			for (var i:int = 0; i < 10; i++) 
			{
				graphics.lineStyle(0, 0xffff00, 0.5);
				graphics.moveTo((6*Math.random() - 3)/frames, (6*Math.random()-3)/frames);
				graphics.lineTo((26*Math.random() - 13)/frames, (26*Math.random()-13)/frames);
			}
		}
		
	}

}