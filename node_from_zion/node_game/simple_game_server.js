var net = require('net'), 
	fs = require('fs'),
	util = require('util'),
	EventEmitter = require('events').EventEmitter;	 
var clients={};
var last=1;
var cnt=0;
var server = net.createServer(function(c) {
	var id=-1;
	//clients[id]=id;	
	//cnt++;
	
	console.log('client '+id+' loged,there are '+cnt+'\n');
	//c.bufferSize=0;
	c.setEncoding('ascii');
	c.setNoDelay();
	c.bufferSize=0;
	util.inherits(c, EventEmitter);
	var key='';
	var clientName='';
	
	var regularReq=function(ch){
		//console.log(id+'\n');
		
		server.emit('msg',id,ch);
	}
	var writeClients=function(){
		//send clients list for current connection
		var ch={};
		ch.you=id;
		ch.data=clients;
		var jstr=JSON.stringify(ch)+'\n';
		console.log(jstr);
		c.write('0'+'C'+jstr+'\n');
		var add={};
		add.cid=id;
		jstr=JSON.stringify(add)+'\n';
		console.log(jstr);
		//c.write(jstr+'\n');
		server.emit('msg',id,'0'+'A'+jstr);
	}
	var writeLeave=function(){
		//broadcast leave messsage
		var ch={};
		ch.cid=id;
		var jstr=JSON.stringify(ch)+'\n';
		console.log(jstr);
		server.emit('msg',id,'0'+'L'+jstr);
	}
	var firstReq=function(ch){
		console.log(id+' first request\n');
		if(/policy-file-request/.test(ch)){
			console.log("sending cross for sockets\n");	
			c.end('<?xml version="1.0" encoding="UTF-8"?>'
				+'<!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd">'
				+'<cross-domain-policy>'
				+'<allow-access-from domain="*" to-ports="8080,8081"/>'
				+'</cross-domain-policy>');	
			return;
		}
		var pp=(/([a-f|0-9]+)/.exec(ch));
		console.log('I get :'+ch);
		if(pp){
			key=pp[1];
			//if(key in authData){
				//clientName=authData[key];
				//c.write(id);
				c.removeListener('data',firstReq);
				c.on('data',regularReq);
				id=last;
				last++;
				writeClients();
				clients[id]=id;
				server.on('msg',thisTok);
				return;
			//}
		}
		c.end();		
	}
	c.on('data',firstReq);	
	var thisTok=function(cli,text){
		thisTok(cli,text,0);
	}
	var thisTok=function(cli,text,tself){
		if(clients[id]==-1){
			console.log('listner for '+id+' removed\n');
			server.removeListener('msg',thisTok);
			return;
		}
		try{
			//console.log('!!'+id+text+'\n');			
			if(cli!=id)
				c.write(text);
		}catch(err){
			console.log(err);
			thisEnd();
			return;
		}
	};
	var thisEnd=function(){
		server.removeListener('msg',thisTok);
		if(clients[id]==-1){
			return;
		}
		cnt--;
		clients[id]=-1;
		console.log(id+' left\n');
		writeLeave();
		//server.emit('msg',id,':left');
	};
	c.on('end',thisEnd);
	c.on('close',thisEnd);
	c.on('error',function(e){
		console.log('errrrr'+e);
		thisEnd();
	});
		
});
util.inherits(server, EventEmitter);
server.on('close',function(){
	console.log('closed');
});
server.listen(8080);
console.log('started');


var daemon = require('../node_modules/daemon');

fs.open('simple_game_server_stdout.log', 'w+', function (err, fd) {
	daemon.start(fd);
	daemon.lock('/tmp/simple_game_server.pid');
});