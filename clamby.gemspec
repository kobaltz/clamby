# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clamby/version'

Gem::Specification.new do |spec|
  spec.name          = "clamby"
  spec.version       = Clamby::VERSION
  spec.authors       = ["kobaltz"]
  spec.email         = ["dave@k-innovations.net"]
  spec.summary       = "Scan file uploads with ClamAV"
  spec.description   = "Clamby allows users to scan files uploaded with Paperclip or Carrierwave. If a file has a virus, then you can delete this file and discard it without causing harm to other users."
  spec.homepage      = "https://github.com/kobaltz/clamby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
