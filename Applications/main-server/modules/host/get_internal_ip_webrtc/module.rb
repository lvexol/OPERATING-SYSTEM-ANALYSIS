#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_internal_ip_webrtc < Server::Core::Command
  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

    configuration = Server::Core::Configuration.instance
    return unless configuration.get('server.extension.network.enable') == true

    return unless @datastore['results'] =~ /IP is ([\d.,]+)/

    # save the network host
    ips = Regexp.last_match(1).to_s.split(/,/)
    session_id = @datastore['serverhook']
    if !ips.nil? && !ips.empty?
      os = Server::Core::Models::BrowserDetails.get(session_id, 'host.os.name')
      ips.uniq.each do |ip|
        next unless ip =~ /^[\d.]+$/
        next if ip =~ /^0\.0\.0\.0$/
        next unless Server::Filters.is_valid_ip?(ip)

        print_debug("Hooked browser has network interface #{ip}")
        Server::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip, os: os)
      end
    end
  end
end
