//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {	
  var url = "<%== @sound_file_uri %>";
  try {	
    var sound = new Audio(url);
    sound.play();
    server.debug("[Play Sound] Played sound successfully: " + url);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=Sound Played", server.are.status_success());
  } catch (e) {
    server.debug("[Play Sound] HTML5 audio unsupported. Could not play: " + url);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=audio not supported", server.are.status_error());
  }
});
