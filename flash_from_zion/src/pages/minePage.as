package pages 
{
	import chars.myRobo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import fonts.Arial;
	import gfx.chatMessage;
	import gfx.earth;
	import com.serialization.json.JSON;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import utils.Base91;
	
	/**
	 * 
	 *  main class in game
	 * 
	 * ...
	 * @author myachin
	 */
	public class minePage extends Sprite
	{
		public static var THIS:minePage = null
		
		public static var myrobo:myRobo;
		
		public static var cameraSprite:Sprite = new Sprite;
		
		public static var currentBlock:int = 0;
		public static var robots:Vector.<myRobo> = new Vector.<myRobo>;
		public static var cheat:Boolean = false;
		public static var des:Boolean = false;
		public static var deepTF:TextField = new TextField;
		public static var de2epTF:TextField = new TextField;
		public static var de3epTF:TextField = new TextField;
		public static var de4epTF:TextField = new TextField;
		
		public static var chatFormTF:TextField = new TextField;
		
		[Embed(source = '../surf.png')]
		public static var _surfClass:Class;		
		public static var _surf:Bitmap = new _surfClass as Bitmap;		
		
		[Embed(source = '../hint.png')]
		public static var _hintClass:Class;		
		public static var _hint:Bitmap = new _hintClass as Bitmap;	
		
		[Embed(source = '../combo_hint.png')]
		public static var _combo_hintClass:Class;		
		public static var _combo_hint:Bitmap = new _combo_hintClass as Bitmap;
		
		[Embed(source = '../livebar.png')]
		public static var _livebarClass:Class;		
		public static var _livebar:Bitmap = new _livebarClass as Bitmap;				
		
		public static var _live:int = 100;
		
		public function minePage() 
		{
			graphics.beginFill(0);
			graphics.drawRect( -10, -10, 820, 520);
			myrobo = new myRobo(0);
			THIS = this;
			
			graphics.beginFill(0);
			graphics.drawRect(0, 0, 800, 500);
			graphics.endFill();
			
			addChild(new earth);
			addChild(cameraSprite);
			
			_surf.y = -300;
			cameraSprite.addChild(_surf);
			cameraSprite.addChild(myrobo);
			
			robots.push(myrobo);
			
			var tf:TextFormat = Arial.getFormat(12, 0xffffff, TextFormatAlign.LEFT);
			deepTF.defaultTextFormat = tf;
			deepTF.x = 660;
			deepTF.y = 10;
			deepTF.width = 400;
			deepTF.mouseEnabled = false;
			addChild(deepTF);
			
			var tf4:TextFormat = Arial.getFormat(20, 0xffffff, TextFormatAlign.CENTER);
			chatFormTF.defaultTextFormat = tf4;
			chatFormTF.x = 40;
			chatFormTF.y = 250;
			chatFormTF.width = 560;
			chatFormTF.height = 30;
			chatFormTF.mouseEnabled = false;
			chatFormTF.maxChars = 50;
			chatFormTF.restrict = "^\n\r";
			chatFormTF.type = TextFieldType.INPUT;
			chatFormTF.border = true;
			chatFormTF.borderColor = 0xffffff;
			chatFormTF.visible = false;
			addChild(chatFormTF);
			
			//TODO CHAT!!!!!
			
			
			var tf2:TextFormat = Arial.getFormat(10, 0x22ff22, TextFormatAlign.LEFT);
			de2epTF.defaultTextFormat = tf2;
			de2epTF.x = 660;
			de2epTF.y = 60;
			de2epTF.width = 400;
			de2epTF.mouseEnabled = false;
			addChild(de2epTF);			
	
			var tf3:TextFormat = Arial.getFormat(10, 0xff2222, TextFormatAlign.LEFT);
			de3epTF.defaultTextFormat = tf3;
			de3epTF.x = 660;
			de3epTF.y = 100;
			de3epTF.width = 400;
			de3epTF.mouseEnabled = false;
			addChild(de3epTF);				
			
			var tf5:TextFormat = Arial.getFormat(10, 0xffffff, TextFormatAlign.LEFT);
			de4epTF.defaultTextFormat = tf5;
			de4epTF.x = 660;
			de4epTF.y = 120;
			de4epTF.width = 400;
			de4epTF.mouseEnabled = false;
			addChild(de4epTF);				
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			var _timer:Timer = new Timer(500);
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, 
				function(e:Event):void
				{
					if (minePage.lastFrameTime + 1000 < getTimer())
					{
						onFrame();
					}
				}
			);
			
			_livebar.x = 652;
			_livebar.y = 33;
			
			addChild(_livebar);
			
			_hint.x = 640;
			_hint.y = 300;
			addChild(_hint);
			
			_combo_hint.x = 640;
			_combo_hint.y = 140;
			
			addChild(_combo_hint);
			
			addChild(liveSprite);
			addEventListener(Event.ADDED_TO_STAGE, 
				function(e:Event):void 
				{ 
					minePage.THIS.stage.focus = minePage.THIS; 
				} );
				
			focusRect = false;
			chatFormTF.focusRect = false;
		}
		
		public static var aniframe:int = 0;
		public static var MOVING:int = 5;
		public static var DIGGING:int = 12;
		public static var syncframe:int = 0;
		
		public static var death:int = 0;
		public static var green:int = 4;
		public static var kills:int = 0;
		
		public static var liveSprite:Sprite = new Sprite;
		public static var lastFrameTime:int;
		
		public function onFrame (e:Event = null) : void
		{
			lastFrameTime = getTimer();
			
			deepTF.text = "x:" + myrobo.gx.toString() + " y: " + myrobo.gy.toString();// + "LISTEN: "
					//+ currentBlock + "\nREAL IN " + Math.floor(myrobo.gy / 25)
					//+ "\n" + "YOUR HEALTH:" + _live;
			
			de2epTF.text = "crystals collected: [ " + green + " ]\n(press ENTER to build box)"; 	
			
			de3epTF.text = "human killed: [ " + kills + " ]";
					
			if ((_live < 0)&&(true))
			{
				sendBlockChanged(0);
				
				myrobo.gx = 10 + Math.floor(Math.random() * 20);
				myrobo.gy = 6 + Math.floor(Math.random() * 8);			
				//cameraSprite.y = -500;
				_live = 100;
				death++;
				return;
			}
			else 
			{
				if (_live > 100) _live = 100;
				liveSprite.graphics.clear();
				liveSprite.graphics.beginFill(0);
				liveSprite.graphics.drawRect(675 + 114 - (114 * (100-_live)/100), 37, (114 * (100-_live) / 100), 19);
				liveSprite.graphics.endFill();
				
			}
			
			// send data sometime:
			if (syncframe++ > 10)
			{
				syncframe = 0;
				sendData();
				//map.testGravity();
				sendBlockChanged(currentBlock);
			}
				
			cameraSprite.y = 0.9*cameraSprite.y + 0.1*(250 - myrobo.y);
			// check aniframes?!
			// 5 frames to move
			
			if ((aniframe == 0) )
			{
				//
				// COLLISION!!!!
				//
				if (map.mapBytes[myrobo.gx + 40 * (myrobo.gy)] != 32 && cheat != true)
				{
					if (map.mapBytes[myrobo.gx + 40 * (myrobo.gy)] != 77)
						_live -= Math.floor(4 * Math.random());
					if (map.mapBytes[myrobo.gx + 40 * (myrobo.gy)] == 77)
						_live -= Math.floor(25 * Math.random());
					sendBzzz(myrobo.gx, myrobo.gy);
					aniframe = MOVING;				
					//addChild(new chatMessage( myrobo.gx*16, myrobo.gy*16 + 19 + cameraSprite.y, "Hi! Hellooo"));
				}
				if (cheat && des)
				{
				sendBzzz(myrobo.gx, myrobo.gy);
				sendBzzz(myrobo.gx, myrobo.gy);
				sendBzzz(myrobo.gx, myrobo.gy);
				sendBzzz(myrobo.gx, myrobo.gy);
				sendBzzz(myrobo.gx, myrobo.gy);
				}
				
				//
				// KEYS BLOCK: 
				//
				if (!minePage.chatFormTF.visible)
				{
					if ((MyaKeyboard.isKey[13]) && (green > 0))
					{
						//
						trace("CHAT="+ minePage.chatFormTF.visible);
						
						if ((myrobo._gy) < 20) return;
						switch(myrobo.position)
						{
							// TODO: CHECK EDGES!
							case "UP":
								sendBOX(myrobo.gx, myrobo.gy - 1);
								break;
							case "DOWN":
								sendBOX(myrobo.gx, myrobo.gy + 1);
								break;
							case "LEFT":
								sendBOX(myrobo.gx - 1, myrobo.gy);
								break;
							case "RIGHT":
								sendBOX(myrobo.gx + 1, myrobo.gy);
								break;							
						}
						aniframe = MOVING;
					}
					else if (MyaKeyboard.isKey[69])
					{
						if (_live < 100)
						{
						if (green > 10)
						{
						_live += 5;
						green -= 10;
						}
						}
					
					}
					else if (MyaKeyboard.isKey[87] || MyaKeyboard.isKey[38])
					{
						myrobo.position = "UP";
						
						// check what i do:
						if ( myrobo.gy > 0)
						if ( map.mapBytes[myrobo.gx + 40*(myrobo.gy - 1)] == 32 || cheat)
						{
							if (myrobo.gy % 50 == 25)
								sendBlockChanged(Math.floor((myrobo.gy - 25) / 25));						
							myrobo.gy--;
							aniframe = MOVING;
						}
						else 
						{
							sendBzzz(myrobo.gx, myrobo.gy - 1);
							aniframe = DIGGING;
						}
						sendData();
					}
					else if (MyaKeyboard.isKey[83] || MyaKeyboard.isKey[40])
					{
						myrobo.position = "DOWN";
						
						if ( map.mapBytes[myrobo.gx + 40*(myrobo.gy + 1)] == 32 || cheat)
						{
							myrobo.gy++;
							if (myrobo.gy % 50 == 0)
								sendBlockChanged(Math.floor(myrobo.gy / 25));
							aniframe = MOVING;
						}
						else 
						{
							sendBzzz(myrobo.gx, myrobo.gy + 1);
							aniframe = DIGGING;
						}
						sendData();
					}
					else if (MyaKeyboard.isKey[65] || MyaKeyboard.isKey[37])
					{
						myrobo.position = "LEFT";
						if (myrobo.gx > 0)
						if ( map.mapBytes[myrobo.gx + 40*(myrobo.gy) - 1] == 32 || cheat)
						{
							myrobo.gx--;
							aniframe = MOVING;
						}
						else 
						{
							sendBzzz( myrobo.gx -1, myrobo.gy );
							aniframe = DIGGING;
						}
						sendData();
					}
					else if (MyaKeyboard.isKey[68] || MyaKeyboard.isKey[39])
					{
						myrobo.position = "RIGHT";
						if (myrobo.gx < 39)
						if ( map.mapBytes[myrobo.gx + 40*(myrobo.gy) + 1] == 32 || cheat)
						{
							myrobo.gx++;
							aniframe = MOVING;
						}
						else 
						{
							sendBzzz(myrobo.gx +1, myrobo.gy);
							aniframe = DIGGING;
						}
						sendData();
					}	
				}
			}
			else aniframe--;
		}
		
		
		//////////////////////////////////////////////////////////////
		///
		//        NETWORKING 
		///
		//////////////////////////////////////////////////////////////
		public var mySocket:gSocket;
		public var isConnected:Boolean = false;
		
		public function startNetworking (e:Event = null) : void
		{
			//var ip:String = "shachty.myachin.com"; //; "212.192.34.43";//"127.0.0.1";//
			var ip:String = "127.0.0.1"; 
			mySocket = new gSocket(ip, 8080, onConnectionEstablished, Preloader.nick);
			mySocket.connect(ip, 8080);	
		}
		
		public function onConnectionEstablished():void
		{
			mySocket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
		}		
		
		public function onData(e:Event):void {
			while (mySocket.bytesAvailable > 0) {
					var str:String = mySocket.readUTFBytes(mySocket.bytesAvailable);
					var hh:Array = str.split('\n');
					for each(var f:String in hh) {
						if(f.length>0)
						onReceive(f);
					}
			}
		}		
		
		public function onReceive(str:String):void
		{
			var obj :Object;
			var js:String;
			switch(str.charAt(2)) {
				case 'C':
					js = str.substr(3);
					obj = com.serialization.json.JSON.decode(js);
					for (var ob:String in obj.data) 
					{
						var oId:int = parseInt(ob);
						if(oId>0)
							addRobo(oId, obj.data[ob]);
						//trace(""ob);
					}						
					checkMyRobo( obj.you );
					isConnected = true;
					break;
				case 'X':
					var id:int = Base91.toInt2byte(str.charAt(0) + str.charAt(1));
					
					if (id == myrobo.id) 
					{
						trace("X BACK");
						return;
					}
					
					for (var i:int = 0; i < robots.length; i++) 
					{
						if (robots[i].id == id) 
						{	
							robots[i].gx = Base91.toInt1byte(str.charAt(3));
							robots[i].gy = Base91.toInt2byte(str.charAt(4) + str.charAt(5));
							
							switch (str.charAt(6))
							{
								case 'U':
									robots[i].position = "UP";
									break;
								case 'D':
									robots[i].position = "DOWN";
									break;
								case 'L':
									robots[i].position = "LEFT";
									break;
								case 'R':
									robots[i].position = "RIGHT";
									break;									
							}
							break;
						}
					}
					break;
				case 'A':
					js = str.substr(3);
					obj = com.serialization.json.JSON.decode(js);
					addRobo(obj.cid, obj.nick);
					break;
				case 'L':
					js = str.substr(3);
					obj = com.serialization.json.JSON.decode(js);
					removeRobo(obj.cid);					
					break;
				case 'M':
					var blockId:int = Base91.toInt2byte(str.charAt(3) + str.charAt(4));
					
					js = str.substr(5);
					
					trace("READ" + blockId + " LEN" + js.length);
					
					if (js.length != 1000)
					{
						//sendBlockChanged(blockId);
						break;
					}

				
					
					for (var j:int = 0; j < 1000; j++) 
					{
						map.mapBytes[j+blockId*1000] = js.charCodeAt(j);
					} 
					break;
					
				case 'Z':
					var _x:int = Base91.toInt1byte(str.charAt(3));
					var _y:int = Base91.toInt2byte(str.charAt(4) + str.charAt(5));
					if (Math.abs(_y - myrobo.gy) < 35) 
					{
						cameraSprite.addChild( new Iskra(_x * 16 +8, _y * 16 + 8, true) );
						trace("isk");
					}
					//trace ('Z ' + _x.toString() + " " + _y.toString());
					break;		
					
				case 'B':
					_x = Base91.toInt1byte(str.charAt(3));
					_y = Base91.toInt2byte(str.charAt(4) + str.charAt(5));
					
					trace(str);
					
					if ((str.charAt(6) == "G") && (Base91.toInt2byte(str.charAt(7) + str.charAt(8)) == myrobo.id))
					{
						green++;
					}
					
					if ((str.charAt(6) == "K") && (Base91.toInt2byte(str.charAt(7) + str.charAt(8)) == myrobo.id))
					{
						kills++;
					}					
					//trace ('B ' + _x.toString() + " " + _y.toString());
					map.mapBytes[_x + _y * 40] = 32;
					break;		
					
				case 'g':
					_x = Base91.toInt1byte(str.charAt(3));
					_y = Base91.toInt2byte(str.charAt(4) + str.charAt(5));
					
					map.mapBytes[_x + _y * 40] = str.charCodeAt(9);
					
					trace(str.charCodeAt(9));
					
					if (Base91.toInt2byte(str.charAt(7) + str.charAt(8)) == myrobo.id)
					{
						green--;
					}
					//trace ('B ' + _x.toString() + " " + _y.toString());
					
					break;			
				case 'Q':
					trace('FROM CHAT!');
					_x = Base91.toInt1byte(str.charAt(3));
					_y = Base91.toInt2byte(str.charAt(4) + str.charAt(5));			
					addChild(new chatMessage( _x*16, _y*16 + 19 + cameraSprite.y, str.substring(6)));					
					break;
				case 'S':
					//trace('PLAYERS ONLINE:');
					de4epTF.text = "PLAYERS ONLINE: " + Base91.toInt2byte(str.charAt(3) + str.charAt(4));	
					break;					
				default:
					trace('TRASH IN SOCKET!');
					trace(str);
					break;
			}
			
		}		
		
		public function addRobo(id:int, nick:String = "."):myRobo
		{
			var newRobo:myRobo = new myRobo(id, false, nick);
			newRobo.id = id;
			newRobo.gx = -50;
			newRobo.gy = -300;
			
			cameraSprite.addChild(newRobo);
			robots.push(newRobo);
			return newRobo;
		}
		
		public function checkMyRobo(id:int):myRobo
		{
			myrobo.id = id;
			return myrobo;
		}		
		
		public function removeRobo(id:int):void
		{
			for (var i:int = 0; i < robots.length; i++) 
			{
				if (robots[i].id == id) 
				{
					cameraSprite.removeChild(robots[i]);
					robots.splice(i, 1);
					break;
				}
			}
		}		
		
		public function sendData():void
		{
			if (!mySocket) return;
			if (!isConnected) return;
			
			var jdata:String = new String();
							
			jdata = 	Base91.toString2byte(myrobo.id) + 
						'X' +
						Base91.toString1byte(myrobo.gx)+
						Base91.toString2byte(myrobo.gy);
						
			switch (myrobo.position)
			{
				case 'UP':
					jdata += 'U';
					break;
				case 'DOWN':
					jdata += 'D';
					break;
				case 'LEFT':
					jdata += 'L';
					break;
				case 'RIGHT':
					jdata += 'R';
					break;									
			}
						
			jdata += '\n';
			
			mySocket.writeUTFBytes(jdata);	
			mySocket.flush();

		}		
		
		public function sendBzzz(_x:int, _y:int):void
		{
			if (!mySocket) return;
			if (!isConnected) return;
			
			cameraSprite.addChild( new Iskra(_x*16 +8, _y*16 +8) );
			
			var jdata:String = new String();
							
			jdata = 	Base91.toString2byte(myrobo.id) + 
						'Z' +
						Base91.toString1byte(_x)+
						Base91.toString2byte(_y);
						
			jdata += '\n';
			
			mySocket.writeUTFBytes(jdata);	
			mySocket.flush();

		}				

		public function sendBOX(_x:int, _y:int):void
		{
			if (!mySocket) return;
			if (!isConnected) return;
			
			//cameraSprite.addChild( new Iskra(_x*16 +8, _y*16 +8) );
			
			var jdata:String = new String();
							
			jdata = 	Base91.toString2byte(myrobo.id) + 
						'G' +
						Base91.toString1byte(_x)+
						Base91.toString2byte(_y);
						
			jdata += '\n';
			
			mySocket.writeUTFBytes(jdata);	
			mySocket.flush();

		}			
		
		public function sendChatText( str:String ):void
		{
			if (!mySocket) return;
			if (!isConnected) return;
			if (str.substr(0, 3) == "!tp")
			{
			
				myrobo.gx = str.split(' ')[1];
				myrobo.gy = str.split(' ')[2];
				return;
			
			}
			if (str.substr(0, 3) == "!gr")
			{
			
				green += 10000;
				return;
			
			}
			if (str.substr(0, 4) == "!box")
			{
			
				sendBOX(str.split(' ')[1], str.split(' ')[2]);
				return;
			
			}
			if (str.substr(0, 3) == "!ch")
			{
			
				cheat = !cheat;
				return;
			
			}
			if (str.substr(0, 3) == "!de" && cheat)
			{
			
				des = !des;
				return;
			
			}
			//cameraSprite.addChild( new Iskra(_x*16 +8, _y*16 +8) );
			addChild(new chatMessage( myrobo.gx*16, myrobo.gy*16 + 19 + cameraSprite.y, str));	
			
			var jdata:String = new String();
							
			jdata = 	Base91.toString2byte(myrobo.id) + 
						'Q' +
						Base91.toString1byte(myrobo.gx)+
						Base91.toString2byte(myrobo.gy);
						
			jdata += str + '\n';
			
			mySocket.writeUTFBytes(jdata);	
			mySocket.flush();

		}					
		
		public function sendBlockChanged(_block:int):void
		{
			currentBlock = _block;
						
			if (!mySocket) return;
			if (!isConnected) return;
			
			//cameraSprite.addChild( new Iskra(_x*16 +8, _y*16 +8) );
			
			var jdata:String = new String();
							
			jdata = 	Base91.toString2byte(myrobo.id) + 
						'Y' +
						Base91.toString2byte(_block);
						
			jdata += '\n';
			
			//trace("BLOK:" + _block.toString());
			
			mySocket.writeUTFBytes(jdata);	
			mySocket.flush();

		}				
		
	}

}