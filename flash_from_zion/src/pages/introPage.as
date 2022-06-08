package pages 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author myachin
	 */
	public class introPage extends Sprite
	{
		[Embed(source = '../intro.png')]
		public static var _introClass:Class;		
		public static var _intro:Bitmap = new _introClass as Bitmap;
		
		public static var THIS:introPage = null;
		
		public function introPage() 
		{
			THIS = this;
			addChild(_intro);
			useHandCursor = true;
			buttonMode = true;
			
			addEventListener(MouseEvent.CLICK, onClick);
				
		}
		
		public function onClick (e:Event = null) : void
		{
			THIS.visible = false;
			Main.THIS.removeChild(THIS);
			Main.THIS.addChild(minePage.THIS);
			minePage.THIS.startNetworking();
		}		
		
	}

}