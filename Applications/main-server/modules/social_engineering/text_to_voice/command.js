//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {	

  var url = server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/objects/msg-<%= @command_id %>.mp3';
  try {
    var sound = new Audio(url);
    sound.play();
    server.debug('[Text to Voice] Playing mp3: ' + url);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=message sent", server.are.status_success());
  } catch (e) {
    server.debug("[Text to Voice] HTML5 audio unsupported. Could not play: " + url);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=audio not supported", server.are.status_error());
  }

});
