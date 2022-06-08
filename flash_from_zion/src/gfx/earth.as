package gfx 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import pages.minePage;
	/**
	 * ...
	 * @author myachin
	 */
	public class earth extends Sprite
	{
		public static var earthbmp:Bitmap;
		public static var earthbmpdata:BitmapData;
		
		[Embed(source = '../tiles.png')]
		public static var _tileClass:Class;		
		public static var _tile:Bitmap = new _tileClass as Bitmap;		
		
		public static var THIS:earth = null;
		
		public function earth() 
		{
			THIS = this;
			earthbmpdata = new BitmapData(640, 500, true, 0x00000000);
			earthbmp = new Bitmap(earthbmpdata);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			addChild(earthbmp);
		}

		public var aniframe:int = 0;
		//var aniframe:int = 0;
		
		public function onFrame (e:Event = null) : void
		{
			// drawing
			aniframe++;
			if (aniframe == 12) aniframe = 0;
			
			var frame4:int = aniframe / 4;
			var frame0121:int = frame4;
			if (frame4 == 3) 
				frame0121 = 1;
			
			var delta:Number = minePage.cameraSprite.y;
			
			var startY:Number = Math.floor( ( -delta) / 16);
			var shift:Number = -(startY * 16 + delta);
			var endY:Number = startY + 34;
			earthbmpdata.fillRect( new Rectangle(0, 0, 640, 500), 0x00000000);
			
			
			for (var i:int = startY; i < endY; i++) 
			{
				if (i < 0) continue;
				for (var j:int = 0; j < 40; j++) 
				{
					switch(map.mapBytes[i * 40 + j])
					{
						case 32:
							break;
						case 97:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(0,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						case 98:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(17,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						case 99:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(51,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;							
						case 110:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(68,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						case 100:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(85,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						// HUMANS	
						case 101:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(102,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;	
						case 102:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(119,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						// BRICKS:	
						case 103:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(136,0,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;	
						// METAL SAND:	
						case 121:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(0,17,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;				
						case 88:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(17,17,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;	
						// MAGMA:
						case 77:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(34 + frame0121*17,17,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;								
						// GRAY:
						case 66:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(85 + frame4*16,17,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;
						// RED BLOCK:
						case 104:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(0,34,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;							
						// KILLER:
						case 105:
							earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(17+ frame4*17,34,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;		
						// CRYSTAL TREE:
						case 106:
							if ((map.mapBytes[i * 40 + j + 41] == 106) && (j%40 != 39))
								earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(0, 51, 16, 16), new Point(j * 16, (i - startY) * 16 - shift));
							else if ((map.mapBytes[i * 40 + j + 39] == 106) && (j%40 != 0))
								earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(32, 51,16,16), new Point(j*16, (i-startY)*16 - shift));
							else
								earthbmpdata.copyPixels(_tile.bitmapData, new Rectangle(16, 51,16,16), new Point(j*16, (i-startY)*16 - shift));
							break;									
					}
				}
			}
			
			earthbmp.bitmapData = earthbmpdata;
		}
	}

}