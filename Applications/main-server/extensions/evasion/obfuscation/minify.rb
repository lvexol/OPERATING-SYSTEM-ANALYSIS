#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Evasion
      require 'uglifier'
      class Minify
        include Singleton

        def need_bootstrap?
          false
        end

        def execute(input, config)
          opts = {
            output: {
              comments: :none
            },
            compress: {
              # show warnings in debug mode
              warnings: (config.get('server.debug') ? true : false),
              # remove dead code
              dead_code: true,
              # remove all server.debug calls (console.log wrapper) unless client debugging is enabled
              pure_funcs: (config.get('server.client_debug') ? [] : ['server.debug']),
              # remove all console.log calls unless client debugging is enabled
              drop_console: (config.get('server.client_debug') ? false : true)
            }
          }
          output = Uglifier.compile(input, opts)
          print_debug '[OBFUSCATION - Minifier] JavaScript has been minified'
          output
        rescue StandardError => e
          print_error "[OBFUSCATION - Minifier] JavaScript couldn't be minified: #{e.messsage}"
          input
        end
      end
    end
  end
end
