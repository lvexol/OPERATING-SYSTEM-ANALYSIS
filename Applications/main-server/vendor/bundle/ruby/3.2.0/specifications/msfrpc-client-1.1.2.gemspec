# -*- encoding: utf-8 -*-
# stub: msfrpc-client 1.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "msfrpc-client".freeze
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["HD Moore".freeze, "Brent Cook".freeze]
  s.date = "2018-11-20"
  s.description = "This gem provides a Ruby client API to access the Rapid7 Metasploit RPC service.".freeze
  s.email = ["x@hdm.io".freeze, "bcook@rapid7.com".freeze]
  s.homepage = "http://www.metasploit.com/".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Ruby API for the Rapid7 Metasploit RPC service".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3"])
end
