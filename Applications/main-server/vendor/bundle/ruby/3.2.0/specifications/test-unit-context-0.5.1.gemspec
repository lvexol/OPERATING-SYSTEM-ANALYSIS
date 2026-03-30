# -*- encoding: utf-8 -*-
# stub: test-unit-context 0.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit-context".freeze
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Karol Bucek".freeze]
  s.date = "2016-02-01"
  s.description = "Makes Test::Unit::TestCases 'contextable' and thus much\neasier to read and write. If you've seen RSpec than it's the very same 'context\ndo ... end' re-invendet for Test::Unit. Inspired by gem 'context' that does a\nsimilar job for the 'old' Test::Unit bundled with Ruby 1.8.x standard libraries.".freeze
  s.email = ["self@kares.org".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/kares/test-unit-context".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Context for Test::Unit (2.x)".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<test-unit>.freeze, [">= 2.4.0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
