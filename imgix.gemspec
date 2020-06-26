# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imgix/version'

Gem::Specification.new do |spec|
  spec.name          = 'imgix'
  spec.version       = Imgix::VERSION
  spec.authors       = ['Kelly Sutton', 'Sam Soffes', 'Ryan LeFevre', 'Antony Denyer', 'Paul Straw', 'Sherwin Heydarbeygi']
  spec.email         = ['kelly@imgix.com', 'sam@soff.es', 'ryan@layervault.com', 'email@antonydenyer.co.uk', 'paul@imgix.com', 'sherwin@imgix.com']
  spec.description   = 'Easily create and sign imgix URLs.'
  spec.summary       = 'Official Ruby Gem for easily creating and signing imgix URLs.'
  spec.homepage      = 'https://github.com/imgix/imgix-rb'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/imgix/imgix-rb/issues',
    'changelog_uri'     => 'https://github.com/imgix/imgix-rb/blob/main/CHANGELOG.md',
    'documentation_uri' => "https://www.rubydoc.info/gems/imgix/#{spec.version}",
    'source_code_uri'   => "https://github.com/imgix/imgix-rb/tree/#{spec.version}"
  }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.0'
  spec.add_dependency 'addressable'
  spec.add_development_dependency 'webmock'
end
