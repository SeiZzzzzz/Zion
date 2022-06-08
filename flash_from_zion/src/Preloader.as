package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.getDefinitionByName;
	import flash.display.Bitmap;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import fonts.Arial;
	
	/**
	 * ...
	 * @author myachin
	 */
	public class Preloader extends MovieClip 
	{
		public static var textField:TextField = new TextField;
		
		[Embed(source = 'bk.png')]
		public static var _bkClass:Class;		
		public static var _bk:Bitmap = new _bkClass as Bitmap;			
		
		public static var enterTF:TextField = new TextField;
		public static var formTF:TextField = new TextField;
		
		public static var okTF:TextField = new TextField;
		
		public static var nick:String = "";
		public static var isOked:Boolean = false;
		
		public function Preloader() 
		{
			addChild(_bk);
			
			var tf:TextFormat = Arial.getFormat(50, 0xffffff, TextFormatAlign.LEFT);
			enterTF.defaultTextFormat = tf;
			enterTF.x = 150;
			enterTF.y = 100;
			enterTF.width = 800;
			enterTF.mouseEnabled = false;
			enterTF.text = "ENTER YOUR NAME"
			addChild(enterTF);			
			
			var spr2:Sprite = new Sprite;
			addChild(spr2);
			
			var tf3:TextFormat = Arial.getFormat(70, 0xffff55, TextFormatAlign.CENTER);
			okTF.defaultTextFormat = tf3;
			okTF.x = 0;
			okTF.y = 300;
			okTF.width = 800;
			okTF.mouseEnabled = false;
			okTF.text = "ok"
			spr2.addChild(okTF);	
			okTF.visible = false;
			spr2.useHandCursor = true;
			spr2.buttonMode = true;
			
			spr2.addEventListener(MouseEvent.CLICK,
				function(e:Event):void
				{
					nick = formTF.text;
					if (isFinished) startup();
					else 
					{
						spr2.visible = false;
						spr.visible = false;
						okTF.visible = false;
						enterTF.visible = false;
						textField.visible = true;
						
						isOked = true;
					}
				});
			
		
			var spr:Sprite = new Sprite;
			addChild(spr);

			spr.graphics.beginFill(0xffffff, 1);
			spr.graphics.drawRect(100,200, 600, 60);
			spr.graphics.endFill();
			spr.graphics.beginFill(0, 1);
			spr.graphics.drawRect(100+5, 200+5, 600-10, 60-10);
			spr.graphics.endFill();
			
			var tf2:TextFormat = Arial.getFormat(30, 0xffffff, TextFormatAlign.CENTER);
			formTF.defaultTextFormat = tf2;
			formTF.x = 0;
			formTF.y = 210;
			formTF.width = 800;
			formTF.mouseEnabled = true;
			formTF.restrict = "a-zA-Z0-9а-яА-Я";
			formTF.maxChars = 8;
			formTF.text = "h e r e";
			formTF.type = TextFieldType.INPUT;
			
			formTF.addEventListener(MouseEvent.MOUSE_DOWN, 
				function(e:Event):void
				{
					if (formTF.text == "h e r e") formTF.text = "";
				});
				
			formTF.addEventListener(FocusEvent.FOCUS_OUT, 
				function(e:Event):void
				{
					if (formTF.text == "") formTF.text = "h e r e";
				});				
			
			addEventListener(Event.ENTER_FRAME, onFrame);	
			addChild(formTF);				
			
			new map;
			
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO show loader
			var tf4:TextFormat = Arial.getFormat(20, 0xffffff, TextFormatAlign.CENTER);
			textField.x = 300;
			textField.y = 300;
			textField.width = 400;
			textField.mouseEnabled = false;
			textField.defaultTextFormat = tf4;
			addChild(textField);
			textField.visible = false;
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// TODO update loader
			textField.text = "LOADING: " + e.bytesLoaded + " loaded / " + e.bytesTotal + " total";
		}
		
		private function checkFrame(e:Event):void 
		{

			
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		public static var isFinished:Boolean = false;
		
		private function loadingFinished():void 
		{
			isFinished = true;
			
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			textField.visible = false;
			//startup();
			if (isOked) startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
		public function onFrame (e:Event = null) : void
		{
			if ((formTF.text == "") || (formTF.text == "h e r e"))
				okTF.visible = false;
			else
				okTF.visible = true;
		}
	}
	
}