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
  s.summary     = %q{A simple and flexible notifier for Twitter, RSS, or email}
  s.description = %q{A simple and flexible notifier for Twitter, RSS, or email}

#  s.required_rubygems_version = ">= 1.3.6" # TODO test earliest dependency
  s.add_development_dependency("minitest")
  s.add_dependency("crack")
  s.add_dependency("slop")
  s.add_dependency("hpricot", ">= 0.8")
  # if gem is being installed on a mac, add a dependency on ruby-growl.
  # note, this is not a fool-proof method of detecting the OS,
  # apparently if return "java" if platform is JRuby
  if RUBY_PLATFORM.downcase.include?("darwin")
    s.add_dependency("ruby-growl", ">= 2.1")
  end

  s.rubyforge_project = "herald"
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end