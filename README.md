# Thermite

[![Linux/OSX build status](https://travis-ci.org/malept/thermite.svg?branch=master)](https://travis-ci.org/malept/thermite)
[![Windows build status](https://ci.appveyor.com/api/projects/status/kneo890m3ypoxril?svg=true)](https://ci.appveyor.com/project/malept/thermite)
[![Code Climate](https://codeclimate.com/github/malept/thermite/badges/gpa.svg)](https://codeclimate.com/github/malept/thermite)
[![Test coverage](https://codeclimate.com/github/malept/thermite/badges/coverage.svg)](https://codeclimate.com/github/malept/thermite/coverage)
[![Inline docs](http://inch-ci.org/github/malept/thermite.svg?branch=master)](http://inch-ci.org/github/malept/thermite)
[![Gem](https://img.shields.io/gem/v/thermite.svg?maxAge=30000)](https://rubygems.org/gems/thermite)

Thermite is a Rake-based helper for building and distributing Rust-based Ruby extensions.

## Features

* Provides wrappers for `cargo` commands.
* Handles non-standard `cargo` installations via the `CARGO` environment variable.
* Opt-in to allow users to install pre-compiled Rust extensions hosted on GitHub releases.
* Opt-in to allow users to install pre-compiled Rust extensions hosted on a third party server.
* Provides a wrapper for initializing a Rust extension via Fiddle.

## Usage

1. Add the following to your gemspec file:

  ```ruby
  spec.extensions << 'ext/Rakefile'
  spec.add_runtime_dependency 'thermite', '~> 0'
  ```

2. Create `ext/Rakefile` with the following code, assuming that the Cargo project root is the same
   as the Ruby project root:

  ```ruby
  require 'thermite/tasks'

  project_dir = File.dirname(File.dirname(__FILE__))
  Thermite::Tasks.new(cargo_project_path: project_dir, ruby_project_path: project_dir)
  task default: %w(thermite:build)
  ```

3. In `Rakefile`, integrate Thermite into your build-test workflow:

  ```ruby
  require 'thermite/tasks'

  Thermite::Tasks.new

  desc 'Run Rust & Ruby testsuites'
  task test: ['thermite:build', 'thermite:test'] do
    # …
  end
  ```

Run `rake -T thermite` to view all of the available tasks in the `thermite` namespace.

### Configuration

Task configuration for your project can be set in two ways:

* passing arguments to `Thermite::Tasks.new`
* adding a `package.metadata.thermite` section to `Cargo.toml`. These settings override the
  arguments passed to the `Tasks` class. Due to the conflict, it is infeasible for
  `cargo_project_path` or `cargo_workspace_member` to be set in this way. Example section:

```toml
[package.metadata.thermite]

github_releases = true
```

Possible options:

* `binary_uri_format` - if set, the interpolation-formatted string used to construct the download
  URI for the pre-built native extension. If the environment variable `THERMITE_BINARY_URI_FORMAT`
  is set, it takes precedence over this option. Either method of setting this option overrides the
  `github_releases` option.
  Example: `https://example.com/download/%{version}/%{filename}`. Replacement variables:
    - `filename` - The value of `Config.tarball_filename`
    - `version` - the crate version from `Cargo.toml`
* `cargo_project_path` - the path to the top-level Cargo project. Defaults to the current working
  directory.
* `cargo_workspace_member` - if set, the relative path to the Cargo workspace member. Usually used
  when it is part of a repository containing multiple crates.
* `github_releases` - whether to look for Rust binaries via GitHub releases when installing
  the gem, and `cargo` is not found. Defaults to `false`.
* `github_release_type` - when `github_releases` is `true`, the mode to use to download the Rust
  binary from GitHub releases. `'cargo'` (the default) uses the version in `Cargo.toml`, along with
  the `git_tag_format` option (described below) to determine the download URI. `'latest'` takes the
  latest release matching the `git_tag_regex` option (described below) to determine the download
  URI.
* `git_tag_format` - when `github_release_type` is `'cargo'` (the default), the
  [format string](http://ruby-doc.org/core/String.html#method-i-25) used to determine the tag used
  in the GitHub download URI. Defaults to `v%s`, where `%s` is the version in `Cargo.toml`.
* `git_tag_regex` - when `github_releases` is enabled and `github_release_type` is `'latest'`, a
  regular expression (expressed as a `String`) that determines which tagged releases to look for
  precompiled Rust tarballs. One group must be specified that indicates the version number to be
  used in the tarball filename. Defaults to the [semantic versioning 2.0.0
  format](https://semver.org/spec/v2.0.0.html). In this case, the group is around the entire
  expression.
* `optional_rust_extension` - prints a warning to STDERR instead of raising an exception, if Cargo
  is unavailable and `github_releases` is either disabled or unavailable. Useful for projects where
  either fallback code exists, or a native extension is desirable but not required. Defaults
  to `false`.
* `ruby_project_path` - the top-level directory of the Ruby gem's project. Defaults to the
  current working directory.
* `ruby_extension_dir` - the directory relative to `ruby_project_path` where the extension is
  located. Defaults to `lib`.

### Example

Using the cliché Rust+Ruby example, the [`rusty_blank`](https://github.com/malept/rusty_blank)
repository contains an example of using Thermite with [ruru](https://github.com/d-unseductable/ruru)
to provide a `String.blank?` speedup extension. While the example uses ruru, this gem should be
usable with any method of integrating Rust and Ruby that you choose.

### Troubleshooting

Debug statements can be written to a file specified by the `THERMITE_DEBUG_FILENAME` environment
variable.

## FAQ

### Why is it named Thermite?

According to Wikipedia:

* The chemical formula for ruby includes Al<sub>2</sub>O<sub>3</sub>, or aluminum oxide.
* Rust is iron oxide, or Fe<sub>2</sub>O<sub>3</sub>.
* A common thermite reaction uses iron oxide and aluminum to produce iron and aluminum oxide:
  Fe<sub>2</sub>O<sub>3</sub> + 2Al → 2Fe + Al<sub>2</sub>O<sub>3</sub>

## [Release Notes](https://github.com/malept/thermite/blob/master/NEWS.md)

## [Contributing](https://github.com/malept/thermite/blob/master/CONTRIBUTING.md)

## Legal

This gem is licensed under the MIT license.
