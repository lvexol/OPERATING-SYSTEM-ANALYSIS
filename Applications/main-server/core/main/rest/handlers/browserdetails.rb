#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    module Rest
      class BrowserDetails < Server::Core::Router::Router
        config = Server::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('server.api_token')
          halt 401 unless Server::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #
        # @note Get all browser details for the specified session
        #
        get '/:session' do
          hb = Server::Core::Models::HookedBrowser.where(session: params[:session]).first
          error 404 if hb.nil?

          details = Server::Core::Models::BrowserDetails.where(session_id: hb.session)
          error 404 if details.nil?

          result = []
          details.each do |d|
            result << { key: d[:detail_key], value: d[:detail_value] }
          end

          output = {
            'count' => result.length,
            'details' => result
          }

          output.to_json
        end
      end
    end
  end
end
