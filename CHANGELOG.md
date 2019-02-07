# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.8.2](https://github.com/CrowdHailer/raxx_static/tree/0.8.2) - 2019-01-07

### Added

- Support for raxx 0.18.0.

## [0.8.1](https://github.com/CrowdHailer/raxx_static/tree/0.8.1) - 2019-01-07

### Fixed

- Requests with method other than GET are passed up the stack.

## [0.8.0](https://github.com/CrowdHailer/raxx_static/tree/0.8.0) - 2019-01-05

### Changed

- Complete rewrite to use `Raxx.Middleware` behaviour, instead of a macro based implementation.

## [0.7.0](https://github.com/CrowdHailer/raxx_static/tree/0.7.0) - 2018-10-28

### Changed

- Depends on Raxx `0.17.0` which separated simple from streaming behaviour.
  This broke some tests and is fixed in this version.
