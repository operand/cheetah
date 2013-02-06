# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cheetah/version"

Gem::Specification.new do |s|
  s.name        = "cheetah"
  s.version     = Cheetah::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Rodriguez"]
  s.email       = ["theoperand@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A simple library for integrating with the CheetahMail API}
  s.description = %q{A simple library for integrating with the CheetahMail API}

  s.rubyforge_project = "cheetah"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakeweb'

  s.add_runtime_dependency 'resque'
  s.add_runtime_dependency 'httmultiparty'

  if RUBY_VERSION < "1.9"
    s.add_runtime_dependency 'system_timer'
  end
end
