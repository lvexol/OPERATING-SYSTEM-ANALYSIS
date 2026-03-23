#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module WebRTC

      #
      # The http handler that manages the WebRTC signals sent from browsers to other browsers.
      #
      class SignalHandler

        R = Server::Core::Models::RtcSignal
        Z = Server::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup()
        end

        def setup()

          # validates the hook token
          server_hook = @data['serverhook'] || nil
          (print_error "serverhook is null";return) if server_hook.nil?

          # validates the target hook token
          target_server_id = @data['results']['targetserverid'] || nil
          (print_error "targetserverid is null";return) if target_server_id.nil?

          # validates the signal
          signal = @data['results']['signal'] || nil
          (print_error "Signal is null";return) if signal.nil?

          # validates that a hooked browser with the server_hook token exists in the db
          zombie_db = Z.first(:session => server_hook) || nil
          (print_error "Invalid serverhook id: the hooked browser cannot be found in the database";return) if zombie_db.nil?

          # validates that a target browser with the target_server_token exists in the db
          target_zombie_db = Z.first(:id => target_server_id) || nil
          (print_error "Invalid targetserverid: the target hooked browser cannot be found in the database";return) if target_zombie_db.nil?

          # save the results in the database
          signal = R.new(
            :hooked_browser_id => zombie_db.id,
            :target_hooked_browser_id => target_zombie_db.id,
            :signal => signal
          )
          signal.save

        end
      end

      #
      # The http handler that manages the WebRTC messages sent from browsers.
      #
      class MessengeHandler

        Z = Server::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup()
        end

        def setup()
          # validates the hook token
          server_hook = @data['serverhook'] || nil
          (print_error "serverhook is null";return) if server_hook.nil?

          # validates the target hook token
          peer_id = @data['results']['peerid'] || nil
          (print_error "peerid is null";return) if peer_id.nil?

          # validates the message
          message = @data['results']['message'] || nil
          (print_error "Message is null";return) if message.nil?

          # validates that a hooked browser with the server_hook token exists in the db
          zombie_db = Z.first(:session => server_hook) || nil
          (print_error "Invalid serverhook id: the hooked browser cannot be found in the database";return) if zombie_db.nil?

          # validates that a browser with the peerid exists in the db
          peer_zombie_db = Z.first(:id => peer_id) || nil
          (print_error "Invalid peer_id: the peer hooked browser cannot be found in the database";return) if peer_zombie_db.nil?

          # Writes the event into the Server Logger
          Server::Core::Logger.instance.register('WebRTC', "Browser:#{zombie_db.id} received message from Browser:#{peer_zombie_db.id}: #{message}")

          # Perform logic depending on message (updating database)
          puts "message = '" + message + "'"
          if (message == "ICE Status: connected")
            # Find existing status message
            stat = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Connected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Connected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message.end_with?("disconnected"))
            stat = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Disconnected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Disconnected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message == "Stayin alive")
            stat = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Stealthed!!"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Peer-controlled stealth-mode"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message == "Coming out of stealth...")
            stat = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => zombie_db.id, :target_hooked_browser_id => peer_zombie_db.id) || nil
            unless stat.nil?
                stat.status = "Connected"
                stat.updated_at = Time.now
                stat.save
            end
            stat2 = Server::Core::Models::Rtcstatus.first(:hooked_browser_id => peer_zombie_db.id, :target_hooked_browser_id => zombie_db.id) || nil
            unless stat2.nil?
                stat2.status = "Connected"
                stat2.updated_at = Time.now
                stat2.save
            end
          elsif (message.start_with?("execcmd"))
            mod = /\(\/command\/(.*)\.js\)/.match(message)[1]
            resp = /Result:.(.*)/.match(message)[1]
            stat = Server::Core::Models::Rtcmodulestatus.new(:hooked_browser_id => zombie_db.id,
                                                           :target_hooked_browser_id => peer_zombie_db.id,
                                                           :command_module_id => mod,
                                                           :status => resp,
                                                           :created_at => Time.now,
                                                           :updated_at => Time.now)
            stat.save
          end

        end

      end
    end
  end
end
