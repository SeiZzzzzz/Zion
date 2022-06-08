package pages 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	/**
	 * ...
	 * @author myachin
	 */
	public class startPage extends Sprite
	{
		[Embed(source = '../zeon1.png')]
		public static var _zeonClass:Class;		
		public static var _zeon:Bitmap = new _zeonClass as Bitmap;
		
		public static var THIS:startPage = null;
		
		public function startPage() 
		{
			THIS = this;
			addChild(_zeon);
			
			var pad:Sprite = new Sprite;
			addChild(pad);
			pad.graphics.beginFill(0, 0);
			pad.graphics.drawRect(486, 333, 221, 47);
			pad.graphics.endFill();
			pad.buttonMode = true;
			pad.useHandCursor = true;
			
			pad.addEventListener(MouseEvent.CLICK, onClick);
		}
			
		public function onClick (e:Event = null) : void
		{
			THIS.visible = false;
			Main.THIS.removeChild(THIS);
			Main.THIS.addChild(introPage.THIS);
			//minePage.THIS.startNetworking();
		}
	}

}