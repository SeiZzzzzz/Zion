package chars 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import fonts.Arial;
	import pages.minePage;
	/**
	 * ...
	 * @author myachin
	 */
	public class myRobo extends Sprite
	{
		[Embed(source = '../robo.png')]
		public static var _roboClass:Class;		
		[Embed(source = '../robo_other.png')]
		public static var _roboOtherClass:Class;			
				
		public var position:String = "DOWN";
		
		public var roboBmp:Bitmap;
		public var roboCont:Sprite;
		
		public var gx:int = -10;
		public var _gy:int = -10;
		
		public function set gy(value:int) : void
		{
			if (minePage.death > 0)
			{
				var s:int = 0;
				trace('here');
			}
			_gy = value;
		}
		public function get gy() : int { return _gy; }
		
		public var tailx:Array = new Array;
		public var taily:Array = new Array;		
		public var tailxs:Array = new Array;
		public var tailys:Array = new Array;
		
		public var id:int = -1;
		public var nick:String = "";
		
		public function myRobo(id:int, isMy:Boolean = true, _nick:String = "_") 
		{
			if (isMy) 
			{
				gx = 10 + Math.floor(Math.random() * 20);
				gy = 6 + Math.floor(Math.random() * 8);
				roboBmp = new _roboClass as Bitmap;
				nick = Preloader.nick;
			}
			else 
			{
				roboBmp = new _roboOtherClass as Bitmap;
				nick = _nick;
			}	
			
			var tf:TextField = new TextField;
			var tft:TextFormat = Arial.getFormat(7, 0xaaaaaa, TextFormatAlign.LEFT);
			tf.defaultTextFormat = tft;
			tf.text = nick;
			tf.x = 9;
			tf.y = -6;
			tf.mouseEnabled = false;
			addChild(tf);
			
			roboCont = new Sprite;
			roboBmp.x = -8;
			roboBmp.y = -8;
			roboCont.addChild(roboBmp);
			roboCont.x = 8;
			roboCont.y = 8;
			addChild(roboCont);
			
			x = (gx * 16);		
			y = (gy * 16);				
			
			for (var i:int = 0; i < 16; i++) 
			{
				tailx[i] = x;
				taily[i] = y;
				tailxs[i] = x;
				tailys[i] = y;
				
			}
			
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public var aimRot:Number = 0;
		
		public function onFrame (e:Event = null) : void
		{
			if (Math.abs(gy - minePage.myrobo.gy) > 50) 
				return;
			
			switch (position)
			{
			case 'DOWN':
				aimRot = 180;
				break;
			case 'UP':
				aimRot = 0;
				break;
			case 'LEFT':
				aimRot = -90;
				break;
			case 'RIGHT':
				aimRot = 90;
				break;				
			}
			
			// smooth rotating
			
			if (roboCont.rotation - aimRot > 180) 
				aimRot += 360;
			if (roboCont.rotation - aimRot < -180) 
				aimRot -= 360;
				
			roboCont.rotation = 0.7 * roboCont.rotation + 0.3 * aimRot;
			
			x = 0.85 * x + 0.15 * (gx * 16);		
			y = 0.85 * y + 0.15 * (gy * 16);		
			
			if (Math.abs(gy * 16 - y) > 200)
			{
				x = (gx * 16);		
				y = (gy * 16);					
				for (var i:int = 0; i < 16; i++) 
				{
					tailx[i] = x;
					taily[i] = y;
					tailxs[i] = x;
					tailys[i] = y;
				}				
				
			}
			
			// tailing
			for (i = 0; i < 16; i++) 
			{
				tailx[i] += 7*(Math.random() - 0.5);
				taily[i] += 7*(Math.random() - 0.5);
				
			// attraction:
				if (i < 4)
				{
					tailx[i] = 0.7 * tailx[i] + 0.3 * x;
					taily[i] = 0.7 * taily[i] + 0.3 * y;
				}
				else 
				{
					tailx[i] = 0.7 * tailx[i] + 0.3 * tailx[i-4];
					taily[i] = 0.7 * taily[i] + 0.3 * taily[i-4];					
				}
				
				tailxs[i] = 0.7 * tailxs[i] + 0.3 * tailx[i];
				tailys[i] = 0.7 * tailys[i] + 0.3 * taily[i];
			}
			
			graphics.clear();
			graphics.lineStyle(0, 0x888888, 0.6);
			for (var j:int = 0; j < 4; j++) 
			{
				graphics.moveTo( 8 ,  8 );
				graphics.lineTo(tailxs[j] + 8 - x, tailys[j] + 8 - y);
				graphics.lineTo(tailxs[j+4] + 8 - x, tailys[j+4] + 8 - y);
				graphics.lineTo(tailxs[j+8] + 8 - x, tailys[j+8] + 8 - y);
				graphics.lineTo(tailxs[j+12] + 8 - x, tailys[j+12] + 8 - y);
			}//*/
		}
	}

}