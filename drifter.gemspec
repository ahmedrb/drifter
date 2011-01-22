# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "drifter/version"

Gem::Specification.new do |s|
  s.name        = "drifter"
  s.version     = Drifter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ahmed Adam"]
  s.homepage    = "http://github.com/ahmedrb/drifter"
  s.summary     = %q{Simple geocoding library for ruby}

  s.rubyforge_project = "drifter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'json', '~> 1.4.6'
end
