package  
{
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author myachin
	 */
	public class map 
	{
		public static var mapBytes:Vector.<int> = new Vector.<int>;
		
		
		public function map() 
		{			
			for (var i:int = 0; i < 40*100000; i++) 
			{
				mapBytes[i] = 32;
				//if (Math.random() > 0.6) 
				//	mapBytes[i] = 97;
				
				
			}
		}
		
	}

}