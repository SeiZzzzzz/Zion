//////////////////////////////////////////
//                                      // 
// 	    COMMON MULTIPLAYER SERVER       //
//      FOR ROOMED AND GEO-GAMES        //
//                                      //       
//      (c) misha zhidik, skit          //
//      (c) sergey myachin on miniLD32  //
//                                      //
//////////////////////////////////////////


//
//       require block
//

var net          = require('net'), // 'net'  for server
    fs           = require('fs'), // for daemonizing
    util         = require('util'), // 'util' for inheritance
    EventEmitter = require('events').EventEmitter;	//  

//	
//       config
//

var MAX_PLAYERS = 8000;	
var END_OF_GRAVITY = 3900;	

//	
//       global vars
//

//
//  list of all clients
//  id pool
//
var idpool = {};

var cnt     = 0;

//
// ROOMS:
// 
// 
//

var rooms   = {};
rooms.zov   = {};
rooms.klast = {};
rooms.klast2 = {};
rooms.zeon1   = {};

rooms.zeon1[0] = -1;

//
// GAMEWORLDS:
//

// ZEON GAME WORLD:
// 40 * 8000 ?

//var zeonMap1;
var zeonMap1 = new Buffer(40*100000);
var zeonGrayMap1 = new Buffer(40*100000);
var zeonGrayMap2 = new Buffer(40*100000);
zeonMap1 = fs.readFileSync('../zeon.map');

var isServerUp = false;

var cleanZeonBlocks = {};
for (var i=0; i<4000; i++)
{
	cleanZeonBlocks[i] = false;
}

zeonGravity();

function saveZeonMap()
{
	console.log(ISODate() + ' world saved. Dirty blocks: ' + dirtyBlocks);
	fs.writeFileSync('../zeon.map.tmp', zeonMap1);
	fs.renameSync('../zeon.map.tmp', '../zeon.map')
}

var SOFTSAND = true;

function zeonPlayersOnlineUpdater()
{
	var online = 0;
	for (var i = 1; i<MAX_PLAYERS; i++)
	{
		if ((rooms.zeon1[i] != undefined))
		{
			online++;
		}
	}
	if (isServerUp)
	{
		server.emit('msg_' + 'zeon1', 0, '00S' + Base91.toString2byte(online) );
	}
}

var dirtyBlocks = 0;

var END_OF_GRAY = 1900;
var START_OF_GRAY = 3;



function zeonGrayReplicator()
{
	for (var i = END_OF_GRAVITY; i >= 1; i--)
	{
		for (var j = 999; j >= 0; j--)
		{
			zeonGrayMap1[i*1000 + j ] = 0;
		}
	}

	for (var i = END_OF_GRAVITY; i >= 1; i--)
	{
		var isClean = true;
		for (var j = 999; j >= 0; j--)
		{
		  //if do someth. make dirty!
		  if( (zeonMap1[i*1000 + j] == 66) && (zeonMap1[i*1000 + j + 40] == 32) )
		  {
			  zeonGrayMap1[i*1000 + j + 40] = 66;
			  isClean = false;
		  }
		  //if do someth. make dirty!
		  if( (zeonMap1[i*1000 + j] == 66) && (zeonMap1[i*1000 + j - 40] == 32) )
		  {
			  zeonGrayMap1[i*1000 + j - 40] = 66;
			  isClean = false;
		  }		  
		  //if do someth. make dirty!
		  if( (zeonMap1[i*1000 + j] == 66) && (zeonMap1[i*1000 + j + 1] == 32) && (j%40 != 39))
		  {
			  zeonGrayMap1[i*1000 + j + 1 ] = 66;
			  isClean = false;
		  }		  
		  //if do someth. make dirty!
		  if( (zeonMap1[i*1000 + j] == 66) && (zeonMap1[i*1000 + j - 1] == 32) && (j%40 != 0))
		  {
			  zeonGrayMap1[i*1000 + j - 1 ] = 66;
			  isClean = false;
		  }		  		  
		}		
		
		if (!isClean)
		{
			cleanZeonBlocks[i] = false;
		}
	}
	
	for (var i = END_OF_GRAVITY; i >= 1; i--)
	{
		for (var j = 999; j >= 0; j--)
		{
			if (zeonGrayMap1[i*1000 + j ] == 66)
				zeonMap1[i*1000 + j] = 66;
		}
	}	
}

// EVERY 4-CYCLES OF GRAVITY => KILLER KILLS GOO!

var gravFrame = 0;
var growFrame = 0;

function zeonGravity()
{
	gravFrame++;
	if (gravFrame > 3) gravFrame = 0;
	growFrame++;
	if (growFrame > 800) growFrame = 0;
	
	if (growFrame == 0)
	{
		for (var i = END_OF_GRAVITY; i >= 1; i--)
		{
			for (var j = 999; j >= 0; j--)
			{
				zeonGrayMap1[i*1000 + j ] = 0;
			}
		}
	}	
	
	dirtyBlocks = 0;
	// blocks! (try)
	for (var i = END_OF_GRAVITY; i >= 0; i--)
	{
		if (cleanZeonBlocks[i] && (growFrame!=0)) continue;
		
		var isClean = true;
		var isDownShift = false;
		var isUpShift = false;
		//gravity in block!
		
		//console.log("BLOCK " + i + " is marked DIRTY");
		
		for (var j = 999; j >= 0; j--)
		{
			if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] == 32) )
			{
				isClean = false;
				
				zeonMap1[i*1000 + j + 40] = zeonMap1[i*1000 + j];
				zeonMap1[i*1000 + j] = 32;
				
				if (j>1000-80) 
				{
					cleanZeonBlocks[i+1] = false;
					isDownShift = true;
				}
				if (j<80) 
				{
					cleanZeonBlocks[i-1] = false;
					isUpShift = true;
				}				
			}
			
			// SOFT SAND
			if ((SOFTSAND))
			{
				if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] % 11 == 0) && (zeonMap1[i*1000 + j + 39] == 32) && (j%40 != 0) )
				{
					isClean = false;
					zeonMap1[i*1000 + j + 39] = zeonMap1[i*1000 + j];
					zeonMap1[i*1000 + j] = 32;
					
					
					if (j>1000-80) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<80) 
					{
						cleanZeonBlocks[i-1] = false;
						isUpShift = true;
					}						
				}			
				else if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] % 11 == 0) && (zeonMap1[i*1000 + j + 41] == 32) && (j%40 != 39))
				{
					isClean = false;
					zeonMap1[i*1000 + j + 41] = zeonMap1[i*1000 + j];
					zeonMap1[i*1000 + j] = 32;
					
					
					if (j>1000-80) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<80) 
					{
						cleanZeonBlocks[i-1] = false;
						isUpShift = true;
					}						
				}							
			}			
			
			//KILLAZ:
			if (( zeonMap1[i*1000 + j] == 105) && (gravFrame == 0))
			{
				zeonMap1[i*1000 + j + 40] = 32;
				zeonMap1[i*1000 + j - 40] = 32;
				if ((j%40 != 39)) zeonMap1[i*1000 + j + 1] = 32;
				if ((j%40 != 0)) zeonMap1[i*1000 + j - 1] = 32;
				isClean = false;
				if (j>1000-80) 
				{
					cleanZeonBlocks[i+1] = false;
					isDownShift = true;
				}
				if (j<80) 
				{
					cleanZeonBlocks[i-1] = false;
					isUpShift = true;
				}						
			}
			
			//CRYSTAL TREE GROWING:
			
				// Pascal's Triangle Tree
				// 100 RULE
				if ( (j%40 > 0) &&
				( zeonMap1[i*1000 + j + 39] == 106) &&
				( zeonMap1[i*1000 + j + 40] != 106) &&
				( zeonMap1[i*1000 + j + 41] != 106) &&		 
				( zeonMap1[i*1000 + j] == 32 )				
				)
				{
					zeonGrayMap1[i*1000 + j] = 106;
					isClean = false;
					if (j>1000-80) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<80) 
					{
						cleanZeonBlocks[i-1] = false;
						isUpShift = true;
					}						
				}
				// 001 RULE
				if ( (j%40 > 0) &&
				( zeonMap1[i*1000 + j + 39] != 106 ) &&
				( zeonMap1[i*1000 + j + 40] != 106 ) &&
				( zeonMap1[i*1000 + j + 41] == 106 ) &&
				( zeonMap1[i*1000 + j] == 32 )
				)
				{
					zeonGrayMap1[i*1000 + j] = 106;
					isClean = false;
					if (j>1000-80) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<80) 
					{
						cleanZeonBlocks[i-1] = false;
						isUpShift = true;
					}						
				}
			
			
			
			//CRYSTAL TREE FALLING:
			if (
			(zeonMap1[i*1000 + j] == 106) 
			&& (( zeonMap1[i*1000 + j + 41] != 106) && (j%40 != 39)) 
			&& (( zeonMap1[i*1000 + j + 39] != 106) && (j%40 != 0)) 
			&& (zeonMap1[i*1000 + j + 40] == 32)
				)			
			{
				zeonMap1[i*1000 + j + 40] = 106;
				zeonMap1[i*1000 + j] = 32;
				isClean = false;
				if (j>1000-80) 
				{
					cleanZeonBlocks[i+1] = false;
					isDownShift = true;
				}
				if (j<80) 
				{
					cleanZeonBlocks[i-1] = false;
					isUpShift = true;
				}						
			}
			
			////MAGMA AND SAND:
			// if( (zeonMap1[i*1000 + j]  == 77) 
				// && (zeonMap1[i*1000 + j + 40] != 77) 
				// && (zeonMap1[i*1000 + j + 40] % 11 == 0) )
			// {
				// isClean = false;
				
				// var temp = zeonMap1[i*1000 + j + 40];
				// zeonMap1[i*1000 + j + 40] = zeonMap1[i*1000 + j];
				// zeonMap1[i*1000 + j] = temp;
				
				// if (j>1000-80) 
				// {
					// cleanZeonBlocks[i+1] = false;
					// isDownShift = true;
				// }
				// if (j<80) 
				// {
					// cleanZeonBlocks[i-1] = false;
					// isUpShift = true;
				// }				
			// }			
			////MAGMA AND ROCK:
			// if( (zeonMap1[i*1000 + j]  == 77) 
				// && (zeonMap1[i*1000 + j + 40] != 32)
				// && ((zeonMap1[i*1000 + j + 40] % 11 != 0) || (zeonMap1[i*1000 + j + 40] == 77))
				// && ( (zeonMap1[i*1000 + j + 39] % 11 == 0) ||
				 // (zeonMap1[i*1000 + j + 39] == 32) )
				// && ( (zeonMap1[i*1000 + j - 1] % 11 == 0) ||
				 // (zeonMap1[i*1000 + j - 1] == 32) )
				// && (j%40 != 0)
				// )
			// {
				// isClean = false;
				
				////var temp = zeonMap1[i*1000 + j + 40];
				// zeonMap1[i*1000 + j ] = zeonMap1[i*1000 + j + 39];
				// zeonMap1[i*1000 + j + 39] = 77;
				
				// if (j>1000-80) 
				// {
					// cleanZeonBlocks[i+1] = false;
					// isDownShift = true;
				// }
				// if (j<80) 
				// {
					// cleanZeonBlocks[i-1] = false;
					// isUpShift = true;
				// }				
			// }			
			
			// if( (zeonMap1[i*1000 + j]  == 77) 
				// && (zeonMap1[i*1000 + j + 40] != 32)
				// && ((zeonMap1[i*1000 + j + 40] % 11 != 0) || (zeonMap1[i*1000 + j + 40] == 77))
				// && ( (zeonMap1[i*1000 + j + 41] % 11 == 0) ||
				 // (zeonMap1[i*1000 + j + 41] == 32) )
				// && ( (zeonMap1[i*1000 + j - 1] % 11 == 0) ||
				 // (zeonMap1[i*1000 + j - 1] == 32) )
				// && (j%40 != 39)
				// )
			// {
				// isClean = false;
				
				////var temp = zeonMap1[i*1000 + j + 40];
				// zeonMap1[i*1000 + j ] = zeonMap1[i*1000 + j+ 41];
				// zeonMap1[i*1000 + j + 41] = 77;
				
				// if (j>1000-80) 
				// {
					// cleanZeonBlocks[i+1] = false;
					// isDownShift = true;
				// }
				// if (j<80) 
				// {
					// cleanZeonBlocks[i-1] = false;
					// isUpShift = true;
				// }				
			// }					
		}
		
		if (isClean)
		{
			cleanZeonBlocks[i] = true;
			//console.log("BLOCK " + i + " is not DIRTY");
		}
		else
		{
			dirtyBlocks++;
			cleanZeonBlocks[i] = false;
			//console.log("BLOCK " + i + " is REAL DIRTY");
			//var evenFloor = (i - i%2);
			//var evenCeil = (i + i%2);
			
			// emiting UPDATE message:
			if (isServerUp)
			{
				var cb1 = i-2;
				var cb2 = i-1;
				var cb3 = i;
				var cb4 = i+1;
				var cb5 = i+2;
				
				if (i%2 == 0)
				{	
					server.emit('msg_' + 'zeon1' + cb1, 0, '00U' + Base91.toString2byte(i) );
					server.emit('msg_' + 'zeon1' + cb3,   0, '00U' + Base91.toString2byte(i) );
					server.emit('msg_' + 'zeon1' + cb5, 0, '00U' + Base91.toString2byte(i) );
					if (isDownShift)
					{
						server.emit('msg_' + 'zeon1' + cb1, 0, '00U' + Base91.toString2byte(i+1) );
						server.emit('msg_' + 'zeon1' + cb3,   0, '00U' + Base91.toString2byte(i+1) );
						server.emit('msg_' + 'zeon1' + cb5, 0, '00U' + Base91.toString2byte(i+1) );			
					}
					if (isUpShift)
					{
						server.emit('msg_' + 'zeon1' + cb1, 0, '00U' + Base91.toString2byte(i-1) );
						server.emit('msg_' + 'zeon1' + cb3,   0, '00U' + Base91.toString2byte(i-1) );
						server.emit('msg_' + 'zeon1' + cb5, 0, '00U' + Base91.toString2byte(i-1) );			
					}					
				}
				else
				{
					server.emit('msg_' + 'zeon1' + cb2, 0, '00U' + Base91.toString2byte(i) );
					server.emit('msg_' + 'zeon1' + cb4, 0, '00U' + Base91.toString2byte(i) );	
					if (isDownShift)
					{
						server.emit('msg_' + 'zeon1' + cb2, 0, '00U' + Base91.toString2byte(i+1) );
						server.emit('msg_' + 'zeon1' + cb4, 0, '00U' + Base91.toString2byte(i+1) );
						
					}	
					if (isUpShift)
					{
						server.emit('msg_' + 'zeon1' + cb2, 0, '00U' + Base91.toString2byte(i-1) );
						server.emit('msg_' + 'zeon1' + cb4, 0, '00U' + Base91.toString2byte(i-1) );			
					}						
				}	
			}
		}
	}
	
	
		for (var i = END_OF_GRAVITY; i >= 1; i--)
		{
			for (var j = 999; j >= 0; j--)
			{
				if (zeonGrayMap1[i*1000 + j ] == 106)
					zeonMap1[i*1000 + j] = 106;
			}
		}	
			
}

setInterval(saveZeonMap, 60000);
setInterval(zeonGravity, 1500);
setInterval(zeonPlayersOnlineUpdater, 3000);

setInterval(zeonGrayReplicator, 77000);

//
//       datetime function
//
function ISODate(){
  var d = new Date();
  function pad(n){return n<10 ? '0'+n : n}
  return d.getUTCFullYear()+'-'
      + pad(d.getUTCMonth()+1)+'-'
      + pad(d.getUTCDate())+' '
      + pad(d.getUTCHours())+':'
      + pad(d.getUTCMinutes())+':'
      + pad(d.getUTCSeconds())+' '
}

///////////////////////////////////////////////////////
//  Base91 functions
//
var Base91 = {};

Base91.base91str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()-_+=[]{},.<>?/;:|~";

Base91.toString1byte = function(num)
{
	if ( num < 0 ) num = 0;
	if ( num > 90 ) num = 90;
	return Base91.base91str.charAt(num);
}

Base91.toString2byte = function(num)
{
	if ( num < 0 ) num = 0;
	if ( num > 8280 ) num = 8280;
	return Base91.base91str.charAt(num/91) + Base91.base91str.charAt(num%91);			
}		

Base91.toString3byte = function(num)
{
	if ( num < 0 ) num = 0;
	if ( num > 753570 ) num = 753570;
	return Base91.base91str.charAt(num/8281) + Base91.base91str.charAt((num/91)%91) + Base91.base91str.charAt(num%91);				
}

Base91.toInt1byte = function(str)
{
	return Base91.base91str.indexOf(str.charAt(0));
}

Base91.toInt2byte = function(str)
{
	return Base91.base91str.indexOf(str.charAt(0))*91 + Base91.base91str.indexOf(str.charAt(1));
}


/*

TODO
AS3 -> JS


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
}*/


////////////////////////////////////////////////////////
//       server
//

var server = net.createServer( function(c) {
	var id = -1;
	var game_type = 'none';
	var nick = "!";
	
	// blockNumber for ZEON geography
	var block = 0;
	
	// connectiion started...
	console.log( ISODate() + ' NEW CLIENT! ALL: ' + cnt );

	// preparing client
	c.setEncoding( 'utf8' );
	c.setNoDelay();
	c.bufferSize = 0;
	
	var key         = '';
	var clientName  = '';
	
	var regularReqZeonSplit  = function( ch )
	{
		var hh = ch.split('\n');
		for(var i=0; i < hh.length; i++) {
			if(hh[i].length > 0)
			{
				regularReqZeon(hh[i] + '\n');
				//console.log( ISODate() + " - rcvd "+ hh[i] );
			}
		}		
	}
	
	var regularReqZeon  = function( ch )
	{
		//console.log( ISODate() + ' received from ' + id + ' msg='+ch);
		var cb1 = block-2;
		var cb3 = block;
		var cb5 = block+2;
		
		if (( ch.charAt(2) != 'Y' ))
		{
			server.emit('msg_' + game_type + cb1, id, ch);
			server.emit('msg_' + game_type + cb3, id, ch);
			server.emit('msg_' + game_type + cb5, id, ch);
		}
		if (ch.charAt(2) == 'Z')
		{
			var _x = Base91.toInt1byte(ch.charAt(3));
			var _y = Base91.toInt2byte(ch.charAt(4) + ch.charAt(5));
			
			//console.log( "TRY 2 DIG x=" + _x + ", y=" + _y + "  " + zeonMap1[_y*40 + _x]);
			// may be we can dig it!
			
			// RED BOX - VERY HARD!
			if ( (zeonMap1[_y*40 + _x] == 104) )
			{
				if (Math.random() < 0.95) return;
			}
			
			if ((Math.random() > 0.4) || (zeonMap1[_y*40 + _x] == 99) || (zeonMap1[_y*40 + _x] == 110)
				|| (zeonMap1[_y*40 + _x] ==101) || (zeonMap1[_y*40 + _x] == 102) || (zeonMap1[_y*40 + _x] == 77)
				|| (zeonMap1[_y*40 + _x] == 66))
			{
				//console.log( "SUCCESS x=" + _x + ", y=" + _y + "  " + ch.substring(2));
				var jstr = "";
				
				if ((zeonMap1[_y*40 + _x] == 98) 
				||  (zeonMap1[_y*40 + _x] == 100)
				||  (zeonMap1[_y*40 + _x] == 104)
				||  (zeonMap1[_y*40 + _x] == 105)
				||  (zeonMap1[_y*40 + _x] == 106)
				)
				{
					jstr = ch.substring(3,6) + "G"  + ch.charAt(0) + ch.charAt(1);
				}
				else if ((zeonMap1[_y*40 + _x] == 101)||  (zeonMap1[_y*40 + _x] == 102))
				{
					jstr = ch.substring(3,6) + "K"  + ch.charAt(0) + ch.charAt(1);
				}				
				else
					jstr = ch.substring(3,6) + " "  + ch.charAt(0) + ch.charAt(1);
				
				zeonMap1[_y*40 + _x] = 32;
				
				server.emit( 'msg_' + game_type + cb1, 0, '00' + 'B' + jstr);
				server.emit( 'msg_' + game_type + cb3, 0, '00' + 'B' + jstr);
				server.emit( 'msg_' + game_type + cb5, 0, '00' + 'B' + jstr);	
				
				cleanZeonBlocks[ Math.floor(_y/25) ] = false;
				if (_y%25 > 22)
					cleanZeonBlocks[ Math.floor(_y/25) + 1] = false;
					
				if ((_y%25 < 2)&&(_y > 24))
					cleanZeonBlocks[ Math.floor(_y/25) - 1] = false;					
				//console.log("BLOCK " + Math.floor(_y/25) + " CHANGED");
			}
		}
		
		// BOX BUILDING:
		if (ch.charAt(2) == 'G')
		{
			//console.log( "ADDBOX x=" + _x + ", y=" + _y + "  " + ch.substring(2));
			var _x = Base91.toInt1byte(ch.charAt(3));
			var _y = Base91.toInt2byte(ch.charAt(4) + ch.charAt(5));
			var jstr = "";
			
			//server restriction check
			if (_y < 20) return;
			
			//jstr = ch.substring(3,6) + " "  + ch.charAt(0) + ch.charAt(1);
		
			var isBuild = false;
			
			if (zeonMap1[_y*40 + _x] == 100)
			{ 
				zeonMap1[_y*40 + _x] = 104; // red BLOCK
				isBuild = true;
			}
			else if (zeonMap1[_y*40 + _x] == 104) 
			{
				zeonMap1[_y*40 + _x] = 105; // GOO KILLER
				isBuild = true;
			}
			else if (zeonMap1[_y*40 + _x] == 105) 
			{
				zeonMap1[_y*40 + _x] = 106; // CRYSTAL TREE
				isBuild = true;
			}
			else if (zeonMap1[_y*40 + _x] != 105)
			{
				zeonMap1[_y*40 + _x] = 100; // GREEN BLOCK
				isBuild = true;
			}
		
			if ( isBuild )
			{
				jstr = ch.substring(3,6) + " "  + ch.charAt(0) + ch.charAt(1) + String.fromCharCode( zeonMap1[_y*40 + _x]) + "\n";
				server.emit( 'msg_' + game_type + cb1, 0, '00' + 'g' + jstr);
				server.emit( 'msg_' + game_type + cb3, 0, '00' + 'g' + jstr);
				server.emit( 'msg_' + game_type + cb5, 0, '00' + 'g' + jstr);	
			}
			
			//zeonMap1[_y*40 + _x] = 100; // GREENBOX
			
			cleanZeonBlocks[ Math.floor(_y/25) ] = false;			
		}
		
		// BLOCK CHANGING!
		if (ch.charAt(2) == 'Y')
		{
			var newblock = Base91.toInt2byte(ch.charAt(3) + ch.charAt(4));
			if (newblock == block) 
				return;
			
			// unlink me
			// CHECK ALL LINKS!!!!!!!
			server.removeListener('msg_' + game_type + block, thisTok);			
			//console.log( ISODate() + " UNLINK id" + id + " FROM BLOCK" + block);
			
			//link!			
			server.on('msg_' + game_type + newblock, thisTok);
			//console.log( ISODate() + " LINK id" + id + " WITH BLOCK" + newblock);
			
			// send new map!
			if (newblock == block)
			{
				// DO NOTHING
			}
			else if (newblock == block + 2)
			{
				zeonSendBlock(newblock);
				zeonSendBlock(newblock+1);
				zeonSendBlock(newblock+2);
			}
			else if ((newblock == block - 2) && (block != 0))
			{
				zeonSendBlock(newblock);
				zeonSendBlock(newblock-1);
				zeonSendBlock(newblock-2);			
			}
			else 
			{
				if (block != 0)
				{
					
					zeonSendBlock(newblock-2);
					zeonSendBlock(newblock-1);
				}
				zeonSendBlock(newblock);				
				zeonSendBlock(newblock+1);
				zeonSendBlock(newblock+2);			
			}
			
			block = newblock;
		}
	}

	var regularReq  = function( ch )
	{
		server.emit('msg_' + game_type,id,ch);
	}
	
	var zeonSendBlock=function(block_id)
	{
		var jstr = Base91.toString2byte(block_id) + zeonMap1.toString('ascii', block_id*1000, block_id*1000 + 1000);
		
		c.write('00' + 'M' + jstr + '\n');
		//console.log( ISODate() + ' SEND BLOCK' + block_id);	
		//console.log( jstr );
	}
	
	var writeClients=function()
	{
		// send clients in room list for current connection
		var ch = {};
		ch.you = id;
		ch.data = rooms[game_type];		
		var jstr = JSON.stringify( ch )+'\n';
		console.log( jstr );
		c.write('00' + 'C' + jstr + '\n');
		var add = {};
		add.cid = id;
		add.nick = nick;
		jstr = JSON.stringify( add ) + '\n';
		console.log( jstr );
		
		server.emit( 'msg_' + game_type, id, '00' + 'A' + jstr);
	}
	
	var writeLeave=function()
	{
		// broadcast leave messsage
		var ch = {};
		ch.cid = id;
		var jstr = JSON.stringify( ch ) + '\n';
		console.log( jstr );
		server.emit( 'msg_' + game_type, id, '00' + 'L' + jstr );
	}
	
	// first requests listener
	var firstReq = function( ch )
	{
		// sending crossdomain.xml 
		if(/policy-file-request/.test( ch )){
			console.log( ISODate() + ' sending cross-domain-policy for sockets' );	
			c.end('<?xml version="1.0" encoding="UTF-8"?>'
				+ '<!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd">'
				+ '<cross-domain-policy>'
				+ '<allow-access-from domain="*" to-ports="*"/>'
				+ '</cross-domain-policy>' );	
			return;
		}
		
		// retrieve other data from new client
		arr = ch.split( ' ' );		
		
		// defining game type:
		if ( arr[0] == 'klasteroids' )
			game_type = 'klast';
		
		if ( arr[0] == 'klas2roids' )
			game_type = 'klast2';

		if ( arr[0] == 'zeonize_me' )
			game_type = 'zeon1';
			
		console.log( ISODate() + ' GAME (IN DATA): ' + ch );
		

		
		// we dont know your game! get out!
		if ( game_type == 'none' ) 
			c.end();	
			console.log( "NONE" );
		
		// changing listeners to regular
		c.removeListener( 'data', firstReq );
		if (game_type == 'zeon1')
		{
			//c.on( 'data', regularReqZeon );
			c.on( 'data', regularReqZeonSplit );
		}
		else
		{
			c.on( 'data', regularReq );
		}
		
		// generating id for new man!
		for (var i = 1; i < MAX_PLAYERS; i++)
		{
			if ( (idpool[i] == -1) || (idpool[i] == undefined) )
			{
				id = i;
				break;
			}
		}
		
		if (id == -1)
		{
			// server reached limit of players
			c.end();
		}
		
		cnt++;
		
		nick = arr[1];

		// send clientlist and 'user added' message
		writeClients();
		

		// add client to idpool and room
		idpool[id] = id;
		
		try
		{
			if (arr[1] != "")
				rooms[game_type][id] = arr[1];
			else
				rooms[game_type][id] = ":";
		}
		catch(err)
		{
			console.log(err);
			c.end();
			return;
		}		
		
		// listener for non-geo-games and global events:
		server.on( 'msg_' + game_type, thisTok);
		
		if (game_type == 'zeon1')
		{
			server.on('msg_' + game_type + block, thisTok);
			console.log( ISODate() + " LINK id" + id + " WITH BLOCK" + block);
			
			// send first part of map to client:
			zeonSendBlock(0);
			zeonSendBlock(1);
			zeonSendBlock(2);
		}
	}
	
	c.on( 'data', firstReq );	
	
	var thisTok = function(cli,text){
		thisTok(cli,text,0);
	}
	
	var thisTok = function(cli,text,tself){
		if ( (idpool[id] == -1) || (idpool[id] == undefined) )
		{
			console.log( ISODate() + ' listner for ' + id + ' removed' );
			server.removeListener( 'msg_' + game_type, thisTok );
			if (game_type == 'zeon1')
				server.removeListener( 'msg_' + game_type + block, thisTok );
			return;
		}
		try
		{
			if ((game_type == 'zeon1') && (text.charAt(2) == 'U') )
			{
				zeonSendBlock( Base91.toInt2byte(text.charAt(3) + text.charAt(4)) );
				return;
			}
				
			if(cli != id)
				c.write(text);
		}
		catch(err)
		{
			console.log(err);
			thisEnd();
			return;
		}
	};
	
	var thisEnd=function()
	{
		server.removeListener( 'msg_' + game_type, thisTok );
		if (game_type == 'zeon1')
			server.removeListener( 'msg_' + game_type + block, thisTok );		
		if( (idpool[id] == -1) || (idpool[id] == undefined) )
		{
			return;
		}
		cnt--;
		
		idpool[id] = undefined;
		
		try
		{
			rooms[game_type][id] = undefined;
		}
		catch(err)
		{
			console.log(err);
			c.end();
			return;
		}		
		console.log( ISODate() + id + ' left' );
		writeLeave();
		//server.emit('msg',id,':left');
	};
	
	
	c.on( 'end', thisEnd );
	c.on( 'close', thisEnd );
	c.on( 'error', function( e )
	{
		console.log(ISODate() + ' ERROR: ' + e);
		thisEnd();
	});
		
});

isServerUp = true;


server.on( 'close', function(){
	console.log(ISODate() + 'closed' );
});

server.listen( 8080 );
console.log( 'started' );

