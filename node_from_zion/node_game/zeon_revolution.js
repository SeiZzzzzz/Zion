//////////////////////////////////////////
//                                      // 
// 	    ZEON MAP CREATOR		        //
//                                      //
//                                      //       
//                                      //
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
	
// config

	
var SOFTSAND = true;
var END_OF_GRAVITY = 3900;	
	
	
var zeonMap1 = new Buffer(40*100000);

// clean for gravity
var cleanZeonBlocks = {};
for (var i=0; i<4000; i++)
{
	cleanZeonBlocks[i] = false;
}
	
// create zeonworld:
for (var i = 0; i < 40*100000; i++) 
{
	zeonMap1[i] = 32;
	if (i<20*40) continue;
	
	// CLASSIC SOIL:
	
	if (Math.random() > 0.5) 
		zeonMap1[i] = 97;
	if (Math.random() > 0.3) 
		zeonMap1[i] = 98;//greenbox
		
	if (Math.random() > 0.9) 
	{
		if (Math.random() > 0.5) 	
			zeonMap1[i] = 99;     //sand		1
		else zeonMap1[i] = 110;   //sand		2
		
		if (Math.random() > 0.75) 	
			zeonMap1[i] = 77;     //sand		1		
		
		if (i > 900 * 40)
		{
			if (Math.random() > 0.7) zeonMap1[i] = 121;     //sand		3
			if (Math.random() > 0.7) zeonMap1[i] = 88;      //sand		4			
		}
		
		if (i > 1900 * 40)
		{
			if (Math.random() > 0.6) zeonMap1[i] = 121;     //sand		3
			if (Math.random() > 0.6) zeonMap1[i] = 88;      //sand		4			
		}		
	}
	
	// HARD THINGS:
	if (Math.sin(i*0.001) > 0.9)
	{
		if (Math.random() > 0.4) 
			zeonMap1[i] = 97;		
		if (Math.random() > 0.9) 
			zeonMap1[i] = 98;//greenbox			
	}
}

//ADD HUMANS
for (var i = 20; i < 100000; i++)
{
	if (Math.random() > 0.5)
	{
		// generate sizes:
		var x = 3 + Math.floor(Math.random()*25);
		var size = 3 + Math.floor(Math.random()*7);
		//BRICKS:
		for (var j = x; j < x+size; j++)
		{
			zeonMap1[i*40 + j]      = 103;
			zeonMap1[i*40 + j + 40] = 103;
			zeonMap1[i*40 + j + 80] = 103;
		}
		//HUMANS:
		for (var j = x+1; j < x+size-1; j++)
		{
			if (Math.random() > 0.5)
				zeonMap1[i*40 + j + 40] = 101;
			else 
				zeonMap1[i*40 + j + 40] = 102;
		}
	}
}

function zeonGravity()
{
	var res = 0;
	// blocks! (try)
	for (var i = END_OF_GRAVITY; i >= 0; i--)
	{
		if (cleanZeonBlocks[i]) continue;
		
		var isClean = true;
		var isDownShift = false;
		//gravity in block!
		for (var j = 999; j >= 0; j--)
		{
			if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] == 32) )
			{
				isClean = false;
				
				zeonMap1[i*1000 + j + 40] = zeonMap1[i*1000 + j];
				zeonMap1[i*1000 + j] = 32;
				
				if (j>1000-40) 
				{
					cleanZeonBlocks[i+1] = false;
					isDownShift = true;
				}
				if (j<40) 
				{
					cleanZeonBlocks[i-1] = false;
				}				
			}
			
			// SOFT SAND
			if ((SOFTSAND) && (j%40 != 0) && (j%40 != 39))
			{
				if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] % 11 == 0) && (zeonMap1[i*1000 + j + 39] == 32))
				{
					isClean = false;
					zeonMap1[i*1000 + j + 39] = zeonMap1[i*1000 + j];
					zeonMap1[i*1000 + j] = 32;
					
					
					if (j>1000-40) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<40) 
					{
						cleanZeonBlocks[i-1] = false;
					}						
				}			
				else if( (zeonMap1[i*1000 + j] % 11 == 0) && (zeonMap1[i*1000 + j + 40] % 11 == 0) && (zeonMap1[i*1000 + j + 41] == 32))
				{
					isClean = false;
					zeonMap1[i*1000 + j + 41] = zeonMap1[i*1000 + j];
					zeonMap1[i*1000 + j] = 32;
					
					
					if (j>1000-40) 
					{
						cleanZeonBlocks[i+1] = false;
						isDownShift = true;
					}
					if (j<40) 
					{
						cleanZeonBlocks[i-1] = false;
					}						
				}							
			}		
			// MAGMA AND SAND:
			if( (zeonMap1[i*1000 + j]  == 77) 
				&& (zeonMap1[i*1000 + j + 40] != 77) 
				&& (zeonMap1[i*1000 + j + 40] % 11 == 0) )
			{
				isClean = false;
				
				var temp = zeonMap1[i*1000 + j + 40];
				zeonMap1[i*1000 + j + 40] = zeonMap1[i*1000 + j];
				zeonMap1[i*1000 + j] = temp;
				
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
		
		if (isClean)
		{
			cleanZeonBlocks[i] = true;
		}
		else
		{
			res++;
			cleanZeonBlocks[i] = false;
		}
	}
	
	return res;
}

function saveZeonMap()
{
	fs.writeFileSync('../zeon.map', zeonMap1);
}

for (var i=0;i<100;i++)
{
	console.log( i + ' step of gravity: ' + zeonGravity() + 'dirty blox;');
	;
}

saveZeonMap();