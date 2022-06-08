//////////////////////////////////////////
//                                      // 
// 	    ADD  GRAY SEEDS TO 	ZION        //
//                                      //
//                                      //       
//                                      //
//      (c) sergey myachin              //
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
zeonMap1 = fs.readFileSync('../zeon.map');


	/* REMOVING GOO
	if (zeonMap1[i] == 66) 
	{
		if (Math.random() > 0.99)
			zeonMap1[i] = 66;
		else 
			zeonMap1[i] = 32;
	}*/
	
	
	/* ADDING TREES:
	
	if (Math.random() > 0.999)
		zeonMap1[i] = 106;	*/
		
// create zeonworld:
for (var i = 0; i < 40*125; i++) 
{
	zeonMap1[i] = 32;
	if (i<20*40) continue;
	
	if (zeonMap1[i] != 32) continue;
	
	// CLASSIC SOIL:
	
	if (Math.random() > 0.8) 
		zeonMap1[i] = 97;
	if (Math.random() > 0.9) 
		zeonMap1[i] = 98;//greenbox
		
	if (Math.random() > 0.2) 
	{
		if (Math.random() > 0.5) 	
			zeonMap1[i] = 99;     //sand		1s
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
/*
// ADD HUMANS
for (var i = 20; i < 100000; i++)
{
	if (Math.random() > 0.94)
	{
		// generate sizes:
		var x = 3 + Math.floor(Math.random()*25);
		var size = 3 + Math.floor(Math.random()*7);
		// BRICKS:
		for (var j = x; j < x+size; j++)
		{
			zeonMap1[i*40 + j]      = 103;
			zeonMap1[i*40 + j + 40] = 103;
			zeonMap1[i*40 + j + 80] = 103;
		}
		// HUMANS:
		for (var j = x+1; j < x+size-1; j++)
		{
			if (Math.random() > 0.5)
				zeonMap1[i*40 + j + 40] = 101;
			else 
				zeonMap1[i*40 + j + 40] = 102;
		}
	}
}		*/


fs.writeFile('../zeon.map', zeonMap1);
