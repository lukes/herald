# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "herald/version"

Gem::Specification.new do |s|
  s.name        = "herald"
  s.version     = Herald::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luke Duncalfe"]
  s.email       = ["lduncalfe@eml.cc"]
  s.homepage    = "http://github.com/lukes/herald"
  s.summary     = %q{A simple notifier for Twitter, RSS, or email}
  s.description = %q{A simple and flexible notifier for Twitter, RSS, or email}

  s.required_rubygems_version = ">= 1.3.6" # TODO test earliest dependency
  s.add_development_dependency "minitest"
  s.add_dependency "crack"
  s.rubyforge_project         = "herald"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
#  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end