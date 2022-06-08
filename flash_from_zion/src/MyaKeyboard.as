package  
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import pages.minePage;
	
	/**
	 * ...
	 * @author myachin
	 */
	
	public class MyaKeyboard extends EventDispatcher
	{
		public static var _stage:Stage;
		
		public static var isKey:Vector.<Boolean>  = new Vector.<Boolean>;
		
		public static const KEYBOARD_TOUCH : String = 'mya_keyboard_touch';
		public static const KEYBOARD_UP    : String = 'mya_keyboard_up';
		public static const KEYBOARD_DOWN  : String = 'mya_keyboard_down';
		
		public static var THIS:MyaKeyboard = null;
		
		public static function init( stage:Stage ):void
		{
			THIS = new MyaKeyboard;
			
			for (var i:int = 0; i < 1500; i++) 
			{
				isKey[i] = false;
			}
			
			_stage = stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey);
			_stage.addEventListener(KeyboardEvent.KEY_UP, offkey);
			Main.THIS.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, offkeyAll);					
			_stage.focus = Main.THIS;		
		}
		
		private static function onkey(event:KeyboardEvent = null):void 
		{
			isKey[event.keyCode] = true;
			THIS.dispatchEvent(new Event(KEYBOARD_TOUCH));
			THIS.dispatchEvent(new Event(KEYBOARD_DOWN));
			

		}
		
		private static function offkey(event:KeyboardEvent = null):void 
		{
			isKey[event.keyCode] = false;
			THIS.dispatchEvent(new Event(KEYBOARD_TOUCH));
			THIS.dispatchEvent(new Event(KEYBOARD_UP));
			
			//
			// 'T' is pressed:
			//
			
			if (event.keyCode == 84)
			{
				if (minePage.THIS)
				if (!minePage.chatFormTF.visible)
				{
					minePage.chatFormTF.text = "";
					minePage.chatFormTF.visible = true;
					_stage.focus = minePage.chatFormTF;
				}
			}			
			
			//
			// 'ENTER' is pressed:
			//
			
			if (event.keyCode == 13)
			{
				if (minePage.THIS)
				if (minePage.chatFormTF.visible)
				{
					//minePage.chatFormTF.text = "";
					_stage.focus = minePage.THIS;
					minePage.chatFormTF.visible = false;		
					if (minePage.chatFormTF.text != "")
						minePage.THIS.sendChatText(minePage.chatFormTF.text);
					
				}
			}					
		}	
		
		private static function offkeyAll(e:Event = null):void 
		{
			for (var i:int = 0; i < 150; i++) 
			{
				isKey[i] = false;
			}
		}				
	}

}