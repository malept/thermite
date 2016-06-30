# Changes by Version

## Unreleased

### Added

* Config options can be set in `Cargo.toml` (and overrides the options set in the `Thermite::Tasks`
  constructor)

### Changed

* Git tag formats are configurable via `git_tag_format` - defaults to basic semver format

### Fixed

* Accessing the TOML config file when searching for Rust binaries

## [0.1.0] - 2016-06-28

Initial release.

[0.1.0]: https://github.com/malept/thermite/releases/tag/v0.1.0
