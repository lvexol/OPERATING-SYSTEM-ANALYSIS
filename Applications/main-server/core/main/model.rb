#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    class Model < ActiveRecord::Base
      # Tell ActiveRecord that this is not a model
      self.abstract_class = true
    end
  end
end
