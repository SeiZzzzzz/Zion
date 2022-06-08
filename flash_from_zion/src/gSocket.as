package  
{
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;
	import flash.system.Security;
	/**
	 * ...
	 * @author Misha
	 */
	public class gSocket extends Socket	{
		
		private var authKey:String = new String("zeonize_me ");
		private var ID:String = new String();
		private var callback:Function = null;
		
		public static var THIS:gSocket = null;
		
		public function gSocket(host:String = null, port:uint = 0, callback:Function = null, nick:String = ".") {
			
			THIS = this;
			
			super();
			this.callback = callback;
			config();
			authKey += nick;
			
			
			//if (host && port)
			//super.connect(host, port);
		}
		
		
		private function config():void {
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
		public function connectHandler(e:Event):void {
			writeUTFBytes(authKey);
			flush();
			callback();

		}
		public function dataHandler(e:Event):void {
			var recvData:String = readUTFBytes(bytesAvailable);			
		}
		
		private function closeHandler(e:Event):void {
			//trace
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
			//trace;
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			//trace
		}
	}
}