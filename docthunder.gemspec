# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'docthunder'

Gem::Specification.new do |s|
  s.name        = "DocThunder"
  s.version     = DocThunder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James Walmsley"]
  s.email       = ["james@fullfat-fs.co.uk"]
  s.homepage    = "http://github.com/jameswalmsley/DocThunder"
  s.summary     = "An OO replacement for Docurium!"
  s.description = "Produces the standard docurium HTML site by default, but can easily be retargeted to other outputs using templates"

  s.rubyforge_project = 'DocThunder'

  s.add_dependency "version_sorter", "~>1.1.0"
  s.add_dependency "mustache", ">= 0.99.4"
  s.add_dependency "rocco", "= 0.7.0"
  s.add_dependency "gli"
  s.add_dependency "colored"
  s.add_development_dependency "bundler",   "~>1.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
