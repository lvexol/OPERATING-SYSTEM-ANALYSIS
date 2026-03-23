#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Gmail_phishing < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    xss_hook_url = "#{base_host}/demos/plain.html"
    logout_gmail_interval = 10_000
    wait_seconds_before_redirect = 1000
    [
      { 'name' => 'xss_hook_url',
        'description' => 'The URI including the XSS to hook a browser. If the XSS is not exploitable via an URI, ' \
        'simply leave this field empty, but this means you will loose the hooked browser after executing this module.',
        'ui_label' => 'XSS hook URI',
        'value' => xss_hook_url,
        'width' => '300px' }, {
          'name' => 'logout_gmail_interval',
          'description' => 'The victim is continuously loged out of Gmail. This is the interval in ms.',
          'ui_label' => 'Gmail logout interval (ms)',
          'value' => logout_gmail_interval,
          'width' => '100px'
        }, {
          'name' => 'wait_seconds_before_redirect',
          'description' => 'When the user submits his credentials on the phishing page, we have to wait (in ms) ' \
          'before we redirect to the real Gmail page, so that Server gets the credentials in time.',
          'ui_label' => 'Redirect delay (ms)',
          'value' => wait_seconds_before_redirect,
          'width' => '100px'
        }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
