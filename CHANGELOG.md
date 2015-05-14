# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.3] - May 14, 2015
### Fixed
- Fixed a bug where URLs as the path component for Web Proxy sources would not be encoded would generate URLs that would result in a 400 Bad Request. [#8](https://github.com/imgix/imgix-rb/pull/8)

## [0.3.2] - May 11, 2015
### Fixed
- Fixed a bug where the library would not work if tokens were not present.
