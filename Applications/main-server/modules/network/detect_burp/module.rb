#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_burp < Server::Core::Command
  def post_execute
    save({ 'result' => @datastore['result'] })

    configuration = Server::Core::Configuration.instance
    return unless configuration.get('server.extension.network.enable') == true
    return unless @datastore['results'] =~ /^has_burp=true&response=PROXY ([\d.]+:\d+)/

    ip = Regexp.last_match(1).split(':')[0]
    port = Regexp.last_match(1).split(':')[1]
    session_id = @datastore['serverhook']
    if Server::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found network service [ip: #{ip}, port: #{port}]")
      Server::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: 'http', ip: ip, port: port, type: 'Burp Proxy')
    end
  end
end
