package fonts 
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author myachin
	 */
	public class Arial 
	{
		//
		[Embed(source = "arial.ttf", fontName = "Arial", mimeType = 'application/x-font', unicodeRange = "U+0000-U+007e,U+0400-U+044f,U+0451", embedAsCFF='false')]
		public static const arialFont:Class;	
		
		public function Arial() {}			
					
		public static function getFormat(size:uint, color:uint = 0x000000, align:String = TextFormatAlign.CENTER):TextFormat
		{
			var format:TextFormat		= new TextFormat();
			format.font		     		= "Arial";
			format.color				= color;
			format.size                 = size;
			format.align 				= align;
			
			return format;
		}		
	}

}