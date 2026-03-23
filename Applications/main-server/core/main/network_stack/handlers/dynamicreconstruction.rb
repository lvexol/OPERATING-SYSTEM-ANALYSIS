#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module NetworkStack
      module Handlers
        # @note DynamicHandler is used reconstruct segmented traffic from the hooked browser
        class DynamicReconstruction < Server::Core::Router::Router
          # @note holds packet queue
          PQ = []

          # @note obtain dynamic mount points from HttpHookServer
          MOUNTS = Server::Core::HttpServer.instance.mounts

          before do
            error 404 if params.empty?
            headers 'Pragma' => 'no-cache',
                    'Cache-Control' => 'no-cache',
                    'Expires' => '0'
          end

          # Combines packet information and pushes to PQ (packet queue), then checks packets
          get '/' do
            headers 'Pragma' => 'no-cache',
                    'Cache-Control' => 'no-cache',
                    'Expires' => '0',
                    'Content-Type' => 'text/javascript',
                    'Access-Control-Allow-Origin' => '*',
                    'Access-Control-Allow-Methods' => 'POST, GET'
            begin
              PQ << {
                serverhook: params[:bh],
                stream_id: Integer(params[:sid]),
                packet_id: Integer(params[:pid]),
                packet_count: Integer(params[:pc]),
                data: params[:d]
              }
            rescue TypeError, ArgumentError => e
              print_debug "Hooked browser returned an invalid argument: #{e}"
            end

            Thread.new do
              check_packets
            end
          end

          # Check packets goes through the PQ array and attempts to reconstruct the stream from multiple packets
          def check_packets
            checked = []
            PQ.each do |packet|
              next if checked.include?(packet[:serverhook] + ':' + String(packet[:stream_id]))

              checked << (packet[:serverhook] + ':' + String(packet[:stream_id]))
              pc = 0
              PQ.each do |p|
                pc += 1 if packet[:serverhook] == p[:serverhook] and packet[:stream_id] == p[:stream_id]
              end
              next unless packet[:packet_count] == pc

              packets = expunge(packet[:serverhook], packet[:stream_id])
              data = ''
              packets.each_with_index do |sp, _i|
                data += sp[:data] if packet[:serverhook] == sp[:serverhook] and packet[:stream_id] == sp[:stream_id]
              end
              b64 = Base64.decode64(data)
              begin
                res = JSON.parse(b64).first
                res['serverhook'] = packet[:serverhook]
                res['request'] = request
                session_key = Server::Core::Configuration.instance.get('server.http.hook_session_name')
                res['serversession'] = request.cookies[session_key] ||
                                    request.params[session_key] ||
                                    request.env[session_key]

                execute(res)
              rescue JSON::ParserError => e
                print_debug 'Network stack could not decode packet stream.'
                print_debug 'Dumping Stream Data [base64]: ' + data
                print_debug 'Dumping Stream Data: ' + b64
              end
            end
          end

          # Delete packets that have been reconstructed, return deleted packets
          # @param [String] serverhook Beefhook of hooked browser
          # @param [Integer] stream_id The stream ID
          def expunge(serverhook, stream_id)
            packets = PQ.select { |p| p[:serverhook] == serverhook and p[:stream_id] == stream_id }
            PQ.delete_if { |p| p[:serverhook] == serverhook and p[:stream_id] == stream_id }
            packets.sort_by { |p| p[:packet_id] }
          end

          # Execute is called once a stream has been rebuilt. it searches the mounts and passes the data to the correct handler
          # @param [Hash] data Hash of data that has been rebuilt by the dynamic reconstruction
          def execute(data)
            handler = get_param(data, 'handler')
            if MOUNTS.has_key?(handler)
              if MOUNTS[handler].instance_of?(Array) and MOUNTS[handler].length == 2
                MOUNTS[handler][0].new(data, MOUNTS[handler][1])
              else
                MOUNTS[handler].new(data)
              end
            end
          end

          # Assist function for getting parameter from hash
          # @param [Hash] query Hash to pull key from
          # @param [String] key The key association to return from `query`
          # @return Value associated with `key`
          def get_param(query, key)
            return nil if query[key].nil?

            query[key]
          end
        end
      end
    end
  end
end
