# -*- encoding: utf-8 -*-
# stub: test-unit-notify 1.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit-notify".freeze
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2014-10-13"
  s.description = "A test result notify extension for test-unit.\nThis provides test result notification support.\n".freeze
  s.email = ["kou@clear-code.com".freeze]
  s.homepage = "https://github.com/test-unit/test-unit-notify".freeze
  s.licenses = ["LGPLv2.1 or later".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A test result notify extension for test-unit.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<test-unit>.freeze, [">= 2.4.9"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<packnga>.freeze, [">= 0"])
  s.add_development_dependency(%q<kramdown>.freeze, [">= 0"])
end
