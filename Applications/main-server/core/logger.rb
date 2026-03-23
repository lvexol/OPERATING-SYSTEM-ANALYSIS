#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

#
# @note log to file
#
module Server
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new("#{$home_dir}/server.log").tap do |log|
        log.progname = name
        log.level = Logger::WARN
      end
    end
  end
end
