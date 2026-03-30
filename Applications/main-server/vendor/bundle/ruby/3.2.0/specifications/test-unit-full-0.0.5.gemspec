# -*- encoding: utf-8 -*-
# stub: test-unit-full 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit-full".freeze
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2016-10-16"
  s.description = "".freeze
  s.email = ["kou@clear-code.com".freeze]
  s.homepage = "http://test-unit.github.io/#test-unit-full".freeze
  s.licenses = ["LGPL-2.1+".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A meta package to use all test-unit extensions.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<test-unit>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<test-unit-runner-tap>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<test-unit-notify>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<test-unit-rr>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<test-unit-context>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
