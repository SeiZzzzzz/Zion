package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import pages.introPage;
	import pages.minePage;
	import pages.startPage;

	/**
	 * ...
	 * @author myachin
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{	
		public static var THIS:Main;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			THIS = this;
			
			MyaKeyboard.init(stage);
			
			new startPage;
			new minePage;
			new introPage;
			addChild(startPage.THIS);
			
			trace(String(' ').charCodeAt(0));
		}

	}

}