#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap
#

class Phonegap_list_files < Server::Core::Command
  def self.options
    [{
      'name' => 'directory',
      'description' => 'List files in this directory',
      'ui_label' => 'Directory',
      'value' => '/',
      'width' => '300px'
    }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
