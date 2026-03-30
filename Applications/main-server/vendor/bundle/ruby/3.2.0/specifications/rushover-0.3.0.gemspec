# -*- encoding: utf-8 -*-
# stub: rushover 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rushover".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brendon Murphy".freeze]
  s.date = "2013-02-20"
  s.description = "A simple ruby Pushover client".freeze
  s.email = ["xternal1+github@gmail.com".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A simple ruby Pushover client".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rest-client>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<contest>.freeze, [">= 0"])
  s.add_development_dependency(%q<fakeweb>.freeze, [">= 0"])
end
