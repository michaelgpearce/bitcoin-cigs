# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "bitcoin_cigs/version"

Gem::Specification.new do |s|
  s.name        = "bitcoin-cigs"
  s.version     = BitcoinCigs::VERSION
  s.authors     = ["Michael Pearce"]
  s.email       = ["michaelgpearce@yahoo.com"]
  s.homepage    = "http://github.com/michaelgpearce/bitcoin-cigs"
  s.summary     = "Create and Verify Bitcoin Signatures"
  s.description = "Create and Verify Bitcoin Signatures."

  s.rubyforge_project = "bitcoin-cigs"

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'rake', '~> 10.0.4'
end
