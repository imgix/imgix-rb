# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [3.1.0](https://github.com/imgix/imgix-rb/compare/2.1.0...3.1.0) - July 28, 2019

* feat: add srcset generation ([#47](https://github.com/imgix/imgix-rb/pull/47))

## [3.0.0](https://github.com/imgix/imgix-rb/compare/2.1.0...3.0.0) - June 7, 2019

* fix: remove deprecated domain sharding functionality ([#46](https://github.com/imgix/imgix-rb/pull/46))

## [2.1.0](https://github.com/imgix/imgix-rb/compare/2.0.0...2.1.0) - May 7, 2019

* Deprecate domain sharding ([#43](https://github.com/imgix/imgix-rb/pull/43)) ([#45](https://github.com/imgix/imgix-rb/pull/45))

## [2.0.0] - February 25, 2019

* Add domain validation during Client initialization [#42](https://github.com/imgix/imgix-rb/pull/42)
* Expand Travis CI config to include bundler v2.x [#41](https://github.com/imgix/imgix-rb/pull/41)

## [1.2.2] - November 14, 2018

* Improvements to memory usage [#35](https://github.com/imgix/imgix-rb/pull/35)

## [1.2.1] - November 5, 2018

* Removed unused `HTTP` dependency [#38](https://github.com/imgix/imgix-rb/pull/37)

## [1.2.0] - October 29, 2018

* Added `Client#purge` method to allow purging assets from our cache [#37](https://github.com/imgix/imgix-rb/pull/38)

## [1.1.0] - February 24, 2016

* Added automatic Base64 encoding for all Base64 variant parameters.
* Properly encoding all keys and values output by `Imgix::Path`.
* Better URL encoding for spaces, with `ERB::Util.url_encode`.
* Normalize trailing `/` in passed hosts.

## [1.0.0] - December 9, 2015
### Changed
- Removed `Client#sign_path` to provide a consistent method and code path for generating URLs. [#16](https://github.com/imgix/imgix-rb/issues/16)
- Changed `:secure` option to the more clear `:use_https` [#11](https://github.com/imgix/imgix-rb/issues/11)
- Changed `:token` option to the more clear `:secure_url_token` [#11](https://github.com/imgix/imgix-rb/issues/11)

### Fixed
- Fixed URL query strings beginning with `?&s=` instead of `?s=` when no other params are present. [#15](https://github.com/imgix/imgix-rb/issues/15)

## [0.3.3] - May 14, 2015
### Fixed
- Fixed a bug where URLs as the path component for Web Proxy sources would not be encoded would generate URLs that would result in a 400 Bad Request. [#8](https://github.com/imgix/imgix-rb/pull/8)

## [0.3.2] - May 11, 2015
### Fixed
- Fixed a bug where the library would not work if tokens were not present.
