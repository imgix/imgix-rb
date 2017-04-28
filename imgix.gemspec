# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imgix/version'

Gem::Specification.new do |spec|
  spec.name          = 'imgix'
  spec.version       = Imgix::VERSION
  spec.authors       = ['Kelly Sutton', 'Sam Soffes', 'Ryan LeFevre', 'Antony Denyer', 'Paul Straw', 'Mario Rosa']
  spec.email         = ['kelly@imgix.com', 'sam@soff.es', 'ryan@layervault.com', 'email@antonydenyer.co.uk', 'paul@imgix.com', 'mario@dwaiter.com']
  spec.description   = 'Easily create and sign imgix URLs.'
  spec.summary       = 'Official Ruby Gem for easily creating and signing imgix URLs.'
  spec.homepage      = 'https://github.com/imgix/imgix-rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.0'
  spec.add_dependency 'addressable'
end
