#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    module Rest
      class Admin < Server::Core::Router::Router
        config = Server::Core::Configuration.instance
        time_since_last_failed_auth = 0

        before do
          # @todo: this code comment is a lie. why is it here?
          # error 401 unless params[:token] == config.get('server.api_token')
          halt 401 unless Server::Core::Rest.permitted_source?(request.ip)

          # halt if requests are inside server.restrictions.api_attempt_delay
          if time_since_last_failed_auth != 0 && !Server::Core::Rest.timeout?('server.restrictions.api_attempt_delay',
                                                                            time_since_last_failed_auth,
                                                                            ->(time) { time_since_last_failed_auth = time })
            halt 401
          end

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # @note Authenticate using the config set username/password to retrieve the "token" used for subsquent calls.
        # Return the secret token used for subsquene tAPI calls.
        #
        # Input must be specified in JSON format
        #
        # +++ Example: +++
        # POST /api/admin/login HTTP/1.1
        # Host: 127.0.0.1:3000
        # Content-Type: application/json; charset=UTF-8
        # Content-Length: 18
        #
        # {"username":"server", "password":"server"}
        #===response (snip)===
        # HTTP/1.1 200 OK
        # Content-Type: application/json; charset=UTF-8
        # Content-Length: 35
        #
        # {"success":"true","token":"122323121"}
        #
        post '/login' do
          request.body.rewind
          begin
            data = JSON.parse request.body.read
            if data['username'].eql?(config.get('server.credentials.user')) && data['password'].eql?(config.get('server.credentials.passwd'))
              return {
                'success' => true,
                'token' => config.get('server.api_token').to_s
              }.to_json
            end

            Server::Core::Logger.instance.register('Authentication', "User with ip #{request.ip} has failed to authenticate in the application.")
            time_since_last_failed_auth = Time.now
            halt 401
          rescue StandardError
            error 400
          end
        end
      end
    end
  end
end
