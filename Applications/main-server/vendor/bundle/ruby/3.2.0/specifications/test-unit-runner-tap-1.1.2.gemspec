# -*- encoding: utf-8 -*-
# stub: test-unit-runner-tap 1.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit-runner-tap".freeze
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Sawyer".freeze, "Kouhei Sutou".freeze]
  s.date = "2014-11-08"
  s.description = "This project provides TAP and TAP-Y/J test output formats for the TestUnit test framework.".freeze
  s.email = ["transfire@gmail.com".freeze, "kou@cozmixng.org".freeze]
  s.homepage = "https://github.com/test-unit/test-unit-runner-tap".freeze
  s.licenses = ["GPL-2".freeze, "GPL-2".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "TAP runners for TestUnit.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<test-unit>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<mast>.freeze, [">= 0"])
  s.add_development_dependency(%q<indexer>.freeze, [">= 0"])
end
