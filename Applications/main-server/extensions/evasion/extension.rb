#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Evasion
      extend Server::API::Extension

      @short_name = 'evasion'
      @full_name = 'Evasion'
      @description = 'Contains Evasion and Obfuscation techniques to prevent the likelihood that Server will be detected'
    end
  end
end

require 'extensions/evasion/evasion'
# require 'extensions/evasion/obfuscation/scramble'
require 'extensions/evasion/obfuscation/minify'
require 'extensions/evasion/obfuscation/base_64'
require 'extensions/evasion/obfuscation/whitespace'
