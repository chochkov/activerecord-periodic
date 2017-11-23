# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "activerecord-periodic/version"

Gem::Specification.new do |s|
  s.name        = "activerecord-periodic"
  s.version     = VERSION
  s.authors     = ["nikola chochkov"]
  s.email       = ["nikola@howkul.info"]
  s.homepage    = ""
  s.licenses    = ["MIT"]
  s.require_paths    = ["lib"]
  s.rubygems_version = %q{>= 1.7.2}
  s.summary     = %q{Extracts AR scopes related to selecting data from periods}
  s.description = %q{Extracts AR scopes related to selecting data from periods}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.add_runtime_dependency "chronic", '~> 0.6.3'
  s.add_development_dependency "activerecord"
  s.add_development_dependency "rspec"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "guard"
  s.add_development_dependency "sqlite3"
end
