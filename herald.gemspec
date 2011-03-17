# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "herald/version"

Gem::Specification.new do |s|
  s.name        = "herald"
  s.version     = Herald::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luke Duncalfe"]
  s.email       = ["luke@alltheworld.co.nz"]
  s.homepage    = "http://github.com/lukes/herald"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "herald"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
end
