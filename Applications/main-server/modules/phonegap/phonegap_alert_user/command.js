//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_alert_user
//
server.execute(function() {
    var title = "<%== @title %>";
    var message = "<%== @message %>";
    var buttonName = "<%== @buttonName %>";

   
    function onAlert() {
        result = "Alert dismissed";
        server.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );    
    }

    navigator.notification.alert(
        message,
        onAlert,      
        title,         
	buttonName
    );
  
});
