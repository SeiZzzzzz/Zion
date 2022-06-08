package utils 
{
	/**
	 * ...
	 * @author myachin
	 */
	public class Base91 
	{
		public static const base:String =       "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()-_+=[]{},.<>?/;:|~";
		public function Base91() 
		{}

		public static function toString1byte(num:int):String
		{
			if ( num < 0 ) num = 0;
			if ( num > 90 ) num = 90;
			return base.charAt(num);
		}
		public static function toString2byte(num:int):String
		{
			if ( num < 0 ) num = 0;
			if ( num > 8280 ) num = 8280;
			return base.charAt(num/91) + base.charAt(num%91);			
		}		
		public static function toString3byte(num:int):String
		{
			if ( num < 0 ) num = 0;
			if ( num > 753570 ) num = 753570;
			return base.charAt(num/8281) + base.charAt((num/91)%91) + base.charAt(num%91);				
		}
		
		
		public static function toInt1byte(str:String):int
		{
			return base.indexOf(str.charAt(0));
		}
		
		public static function toInt2byte(str:String):int
		{
			return base.indexOf(str.charAt(0))*91 + base.indexOf(str.charAt(1));
		}
		
		public static function toInt3byte(str:String):int
		{
			return base.indexOf(str.charAt(0))*8281 + base.indexOf(str.charAt(1))*91 + base.indexOf(str.charAt(2));
		}
		public static function logRotToString1Byte(value:Number):String
		{
			while (value > Math.PI * 2.0) value-= Math.PI * 2.0;
			while (value < -Math.PI * 2.0) value += Math.PI * 2.0;
			if(value < 0) value += Math.PI * 2.0;
			//return toString1byte(int(value * 3));
			return toString1byte(int(value * 91 / (2.0*Math.PI))); 
		}
		public static function getRotFromString1Byte(data:String):Number
		{
			return Number(2.0*Math.PI*toInt1byte(data) / 91.0 );
			//return Number(toInt1byte(data)) / 3.0;
		}
		public static function logFloatToString1Byte(value:Number):String
		{
			if (value < - 6) value = -6;
			if (value > 6) value = 6;
			value = 0;

			return toString1byte(int((2.0*6.0)*value+40.0));
		}
		public static function getFloatFromString1Byte(data:String):Number
		{
			return Number(toInt1byte(data) - 40) / (2.0*6.0);
		}
	}

}