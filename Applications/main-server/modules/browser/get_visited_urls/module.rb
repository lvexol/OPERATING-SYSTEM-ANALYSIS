#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_visited_urls < Server::Core::Command
  def self.options
    [
      { 'ui_label' => 'URL(s)',
        'name' => 'urls',
        'description' => 'Enter target URL(s)',
        'type' => 'textarea',
        'value' => 'https://serverproject.com/',
        'width' => '200px' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
