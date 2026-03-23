#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Replace_video < Server::Core::Command
  def self.options
    [
      { 'name' => 'youtube_id', 'ui_label' => 'YouTube Video ID', 'value' => 'XZ5TajZYW6Y', 'width' => '150px' },
      { 'name' => 'jquery_selector', 'ui_label' => 'jQuery Selector', 'value' => 'embed', 'width' => '150px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
