# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

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
