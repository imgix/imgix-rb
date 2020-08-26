# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [4.0.0](https://github.com/imgix/imgix-rb/compare/3.4.0...4.0.0) - August 26, 2020

* deprecate: host-usage, param_helpers, and prefix-1-ary ([#91](https://github.com/imgix/imgix-rb/pull/91))
* fix: update purge operation api keys ([#93](https://github.com/imgix/imgix-rb/pull/93))

## [3.4.0](https://github.com/imgix/imgix-rb/compare/3.3.1...3.4.0) - August 12, 2020

* fix: deprecate api key versions ([#87](https://github.com/imgix/imgix-rb/pull/87))
* docs(readme): deprecation notice for pre-4.0 api keys ([#88](https://github.com/imgix/imgix-rb/pull/88))

## [3.3.1](https://github.com/imgix/imgix-rb/compare/3.3.0...3.3.1) - July 27, 2020

* fix: ensure host is initialized ([#82](https://github.com/imgix/imgix-rb/pull/82))

## [3.3.0](https://github.com/imgix/imgix-rb/compare/3.2.1...3.3.0) - July 21, 2020

* fix: warn prefix-with-args is deprecated ([#78](https://github.com/imgix/imgix-rb/pull/78))
* fix: warn host has been deprecated in favor of domain ([#76](https://github.com/imgix/imgix-rb/pull/76))
* fix: deprecate ALIASES and corresponding define_method(s) ([#75](https://github.com/imgix/imgix-rb/pull/75))
* fix: deprecate ParamHelpers.rect ([#74](https://github.com/imgix/imgix-rb/pull/74))
* fix: allow rbx-3.107 to fail (travis-config) ([#70](https://github.com/imgix/imgix-rb/pull/70))
* fix: remove ensure even requirement ([#69](https://github.com/imgix/imgix-rb/pull/69))

## [3.2.1](https://github.com/imgix/imgix-rb/compare/3.2.0...3.2.1) - November 15, 2019

* fix: duplicate entries when using `min_width` or `max_width` ([#59](https://github.com/imgix/imgix-rb/pull/59))

## [3.2.0](https://github.com/imgix/imgix-rb/compare/3.1.1...3.2.0) - November 15, 2019

* feat: append variable qualities to dpr srcsets ([#58](https://github.com/imgix/imgix-rb/pull/58))
* refactor: pass srcset modifiers through the `options` parameter ([#57](https://github.com/imgix/imgix-rb/pull/57))
* feat: support defining a min and max width range ([#56](https://github.com/imgix/imgix-rb/pull/56))
* feat: add ability to pass in custom widths ([#55](https://github.com/imgix/imgix-rb/pull/55))
* feat: add ability to configure the srcset width tolerance ([#54](https://github.com/imgix/imgix-rb/pull/54))
* style: drop redundant explicit return statements ([#52](https://github.com/imgix/imgix-rb/pull/52))

## [3.1.1](https://github.com/imgix/imgix-rb/compare/3.1.0...3.1.1) - July 28, 2019

* fix: include dpr parameter when generating a DPR srcset ([#48](https://github.com/imgix/imgix-rb/pull/48))
* ci(travis): change build dist to trusty and remove bundler script ([#49](https://github.com/imgix/imgix-rb/pull/49))

## [3.1.0](https://github.com/imgix/imgix-rb/compare/3.0.0...3.1.0) - July 28, 2019

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
