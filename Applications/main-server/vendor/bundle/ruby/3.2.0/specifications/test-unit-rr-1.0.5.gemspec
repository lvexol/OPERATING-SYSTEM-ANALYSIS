# -*- encoding: utf-8 -*-
# stub: test-unit-rr 1.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit-rr".freeze
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2016-01-18"
  s.description = "You don't need RR setup codes with test-unit-rr. You just require\n\"test/unit/rr\".\n".freeze
  s.email = ["kou@clear-code.com".freeze]
  s.homepage = "https://github.com/test-unit/test-unit-rr".freeze
  s.licenses = ["LGPLv2 or later".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "test-unit-rr is a RR adapter for test-unit.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<test-unit>.freeze, [">= 2.5.2"])
  s.add_runtime_dependency(%q<rr>.freeze, [">= 1.1.1"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<packnga>.freeze, [">= 0"])
  s.add_development_dependency(%q<kramdown>.freeze, [">= 0"])
end
