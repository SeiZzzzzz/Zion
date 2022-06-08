package gfx 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import fonts.Arial;
	/**
	 * ...
	 * @author myachin
	 */
	public class chatMessage extends Sprite
	{
		public var tf:TextField;
		public var bmp:Bitmap;
		
		public function chatMessage(_x:int, _y:int, str:String) 
		{
			if (_y < 0) _y = 0;
			if (_y > 480) _y = 480;
			if (_x < 0) _x = 0;
			if (_x > 640) _x = 640;			
			x = _x;
			y = _y;
			tf = new TextField;
			var ttf:TextFormat = Arial.getFormat(10, 0x000000, TextFormatAlign.LEFT);
			tf.defaultTextFormat = ttf;
			tf.text = str;
			tf.width = 250;
			tf.mouseEnabled = false;
			tf.x = 3;
			
			var tfs:Sprite = new Sprite;
			tfs.addChild(tf);
			
			// defining box:
			var dx:int = tf.textWidth;
			var dy:int = tf.textHeight;
			
			var rx:int = x;
			var ry:int = y;
			
			// invert poisition if overlaps edge of screen
			if ((rx + dx > 800) && (rx - 2*dx - 32 > 0) )
			{
				rx = rx - dx - 32;
			}
			
			x = rx;
			
			var bmpData:BitmapData = new BitmapData(dx + 11, dy + 4, true, 0x00000000);
			var sh:Shape = new Shape;
			sh.graphics.beginFill(0xffffff, 1);
			sh.graphics.drawRoundRect(0,0,dx + 11, dy + 4,3);
			sh.graphics.endFill();
			
			bmpData.draw(sh);
			bmpData.draw(tfs);
			
			bmp = new Bitmap(bmpData);
			bmp.alpha = 0.8;
			addChild(bmp);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public var frames:int = 0;
		public function onFrame (e:Event = null) : void
		{
			if (frames%10 == 0) alpha *= 0.95;
			frames++;
			if (frames > 90)
			{
				tf = null;
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onFrame);
			}
		}
	}

}