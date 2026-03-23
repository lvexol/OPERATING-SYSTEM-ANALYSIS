#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module AdminUI
      module Controllers
        class Panel < Server::Extension::AdminUI::HttpController
          def initialize
            super({
              'paths' => {
                '/' => method(:index)
              }
            })
          end

          # default index page
          def index
            @headers['X-Frame-Options'] = 'sameorigin'
          end
        end
      end
    end
  end
end
