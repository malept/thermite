# Thermite

[![Build Status](https://travis-ci.org/malept/thermite.svg?branch=master)](https://travis-ci.org/malept/thermite)
[![Inline docs](http://inch-ci.org/github/malept/thermite.svg?branch=master)](http://inch-ci.org/github/malept/thermite)
[![Gem](https://img.shields.io/gem/v/thermite.svg?maxAge=300000)](https://rubygems.org/gems/thermite)

Thermite is a Rake-based helper for building and distributing Rust-based Ruby extensions.

## Features

* Provides wrappers for `cargo` commands.
* Handles non-standard `cargo` installations via the `CARGO` environment variable.
* Opt-in to allow users to install pre-compiled Rust extensions hosted on GitHub releases.

## Usage

1. Add `thermite` as a runtime dependency in your gem.
2. In your gemspec, add `Rakefile` to the specification's `extensions` list.
3. In `Rakefile`, add `require 'thermite/tasks'` and then add the tasks to the file by running:

```ruby
Thermite::Tasks.new
```

Run `rake -T` to view all of the available tasks in the `thermite` namespace.

### Configuration

Task configuration for your project can be set in two ways:

* passing arguments to `Thermite::Tasks.new`
* adding a `package.metadata.thermite` section to `Cargo.toml`. These settings override the
  arguments passed to the `Tasks` class. Due to the conflict, it is infeasible for
  `cargo_project_path` to be set in this way. Example section:

```toml
[package.metadata.thermite]

github_releases = true
```

Possible options:

* `cargo_project_path` - the path to the Cargo project. Defaults to the current working directory.
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
  used in the tarball filename. Defaults to `vN.N.N`, where `N` is any n-digit number. In this case,
  the group is around the entire expression.
* `ruby_project_path` - the top-level directory of the Ruby gem's project. Defaults to the
  current working directory.

### Example

Using the cliché Rust+Ruby example, the [`rusty_blank`](https://github.com/malept/rusty_blank)
repository contains an example of using Thermite with [ruru](https://github.com/d-unseductable/ruru)
to provide a `String.blank?` speedup extension. While the example uses ruru, this gem should be
usable with any method of integrating Rust and Ruby that you choose.

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
