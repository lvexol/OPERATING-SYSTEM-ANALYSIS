#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Xssrays
      class Handler < Server::Core::Router::Router
        XS = Server::Core::Models::Xssraysscan
        XD = Server::Core::Models::Xssraysdetail
        HB = Server::Core::Models::HookedBrowser

        get '/' do
          # verify if the request contains the hook token
          # raise an error if it's null or not found in the DB
          server_hook = params[:hbsess] || nil

          if server_hook.nil? || HB.where(session: server_hook).first.nil?
            print_error '[XSSRAYS] Invalid server hook ID: the hooked browser cannot be found in the database'
            return
          end

          # verify the specified ray ID is valid
          rays_scan_id = params[:raysid] || nil
          if rays_scan_id.nil? || !Server::Filters.nums_only?(rays_scan_id)
            print_error '[XSSRAYS] Invalid ray ID'
            return
          end

          case params[:action]
          when 'ray'
            # we received a ray
            parse_rays(rays_scan_id)
          when 'finish'
            # we received a notification for finishing the scan
            finalize_scan(rays_scan_id)
          else
            # invalid action
            print_error '[XSSRAYS] Invalid action'
            return
          end

          headers 'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0',
                  'Access-Control-Allow-Origin' => '*',
                  'Access-Control-Allow-Methods' => 'POST,GET'
        end

        # parse incoming rays: rays are verified XSS, as the attack vector is calling back Server when executed.
        def parse_rays(rays_scan_id)
          xssrays_scan = XS.find(rays_scan_id)
          hooked_browser = HB.where(session: params[:hbsess]).first

          if xssrays_scan.nil?
            print_error '[XSSRAYS] Invalid scan'
            return
          end

          xssrays_detail = XD.new(
            hooked_browser_id: hooked_browser.session,
            vector_name: params[:n],
            vector_method: params[:m],
            vector_poc: params[:p],
            xssraysscan_id: xssrays_scan.id
          )
          xssrays_detail.save

          print_info("[XSSRAYS] Scan id [#{xssrays_scan.id}] received ray [ip:#{hooked_browser.ip}], hooked origin [#{hooked_browser.domain}]")
          print_debug("[XSSRAYS] Ray info: \n #{request.query_string}")
        end

        # finalize the XssRays scan marking the scan as finished in the db
        def finalize_scan(rays_scan_id)
          xssrays_scan = Server::Core::Models::Xssraysscan.find(rays_scan_id)

          if xssrays_scan.nil?
            print_error '[XSSRAYS] Invalid scan'
            return
          end

          xssrays_scan.update(is_finished: true, scan_finish: Time.now)
          print_info("[XSSRAYS] Scan id [#{xssrays_scan.id}] finished at [#{xssrays_scan.scan_finish}]")
        end
      end
    end
  end
end
