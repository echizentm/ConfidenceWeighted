# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confidence_weighted/version'

Gem::Specification.new do |spec|
  spec.name          = 'confidence_weighted'
  spec.version       = ConfidenceWeighted::VERSION
  spec.authors       = ['Maezawa Toshiyuki' 'HARUYAMA Seigo']
  spec.email         = ['echizentm@gmail.com', 'haruyama@unixuser.org']
  spec.description   = %q{Confidence Weighted Classifier}
  spec.summary       = %q{Confidence Weighted Classifier}
  spec.homepage      = 'https://github.com/echizentm/ConfidenceWeighted'
  spec.license       = 'BSD (3-clause)'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
