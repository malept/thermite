# Changes by Version

## Unreleased

### Added

* Write debug output to file, if the `THERMITE_DEBUG_FILENAME` environment variable is set

### Changed

* Relaxed rake version requirement
* Ruby version (major + minor) is considered when generating tarball names

### Fixed

* The library path in the generated tarballs is relative

## [0.3.0] - 2016-07-03

### Added

* `github_release_type`, to add `'cargo'` releases via `Cargo.toml` (default) in addition to the
  existing `'latest'` functionality

### Changed

* `git_tag_format` option introduced in 0.2.0 renamed to `git_tag_regex` - `git_tag_format` is
  specific to `github_release_type: 'cargo'`, while `git_tag_regex` is specific to
  `github_release_type: 'latest'`

## [0.2.0] - 2016-06-30

### Added

* Config options can be set in `Cargo.toml` (and overrides the options set in the `Thermite::Tasks`
  constructor)

### Changed

* Git tag formats are configurable via `git_tag_format` - defaults to basic semver format

### Fixed

* Accessing the TOML config file when searching for Rust binaries

## [0.1.0] - 2016-06-28

Initial release.

[0.3.0]: https://github.com/malept/thermite/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/malept/thermite/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/malept/thermite/releases/tag/v0.1.0
