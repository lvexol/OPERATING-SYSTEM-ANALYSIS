//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

WelcomeTab = function() {

  <%
    hook_url = Server::Core::Configuration.instance.hook_url
  %>


    welcome = " \
              <div style='font:11px tahoma,arial,helvetica,sans-serif;width:500px' > \
              <p><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Hooked Browsers</span></p><br />\
              <p>Left-click any hooked browser to open its control tab. Each browser has the following sub-tabs available:</p><br /> \
              <ul style=\"margin-left:15px;\"><li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>Details:</span> Shows everything collected about the target — OS, browser version, plugins, cookies, screen size, timezone, and more.</li> \
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>Logs:</span> A live log of all activity for this browser session.</li> \
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>Commands:</span> The main control tab. Browse and execute modules against the hooked browser. \
              Modules run as JavaScript inside the target browser and can collect data, manipulate the page, \
              or pivot into the local network of the target.<br /><br />\
              Module status is shown with a colour indicator:<ul>\
              <li><img alt='' src='media/images/icons/green.png'  unselectable='on'> Works silently — target will not notice</li>\
              <li><img alt='' src='media/images/icons/orange.png'  unselectable='on'> Works but may produce visible output to the target</li>\
              <li><img alt='' src='media/images/icons/grey.png'  unselectable='on'> Not yet tested against this browser</li>\
              <li><img alt='' src='media/images/icons/red.png'  unselectable='on'> Confirmed not working against this browser</li></ul><br />\
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>XssRays:</span> Automatically scans all links and forms on the hooked page for reflected XSS vulnerabilities.</li> \
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>Network:</span> Discover and interact with hosts on the target's local network directly from this panel.</li> \
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>WebRTC:</span> Extract the target's real internal IP address and communicate peer-to-peer via WebRTC.</li> \
              </ul><br /> \
              <p>Right-clicking a hooked browser in the left panel gives additional options:</p><br /> \
              <ul style=\"margin-left:15px;\">\
              <li><span style='font:bold 11px tahoma,arial,helvetica,sans-serif'>XssRays:</span> Launch an XSS scan directly from the context menu. Fine-tune scan settings inside the XssRays tab.</li></ul><br /> \
              <p><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Notes</span></p><br />\
              <p>To hook a target browser, direct them to the capture page: <a href='/demos/sample.html' target='_blank'>/demos/sample.html</a></p><br />\
              <br/>\
              </div>\
              ";


  WelcomeTab.superclass.constructor.call(this, {
	region:'center',
	padding:'10 10 10 10',
	html: welcome,
	autoScroll: true,
	border: false
    });
};

Ext.extend(WelcomeTab,Ext.Panel, {}); 
