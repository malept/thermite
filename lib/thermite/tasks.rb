# frozen_string_literal: true
#
# Copyright (c) 2016 Mark Lee and contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'fileutils'
require 'rake/tasklib'
require 'thermite/cargo'
require 'thermite/config'
require 'thermite/custom_binary'
require 'thermite/github_release_binary'
require 'thermite/package'
require 'thermite/util'

#
# Helpers for Rust-based Ruby extensions.
#
module Thermite
  #
  # Create the following rake tasks:
  #
  # * `thermite:build`
  # * `thermite:clean`
  # * `thermite:test`
  # * `thermite:tarball`
  #
  class Tasks < Rake::TaskLib
    include Thermite::Cargo
    include Thermite::CustomBinary
    include Thermite::GithubReleaseBinary
    include Thermite::Package
    include Thermite::Util

    #
    # The configuration used for the Rake tasks. See: {Thermite::Config}
    #
    attr_reader :config

    #
    # Possible configuration options for Thermite tasks:
    #
    # * `binary_uri_format` - if set, the interpolation-formatted string used to construct the
    #   download URI for the pre-built native extension. If the environment variable
    #   `THERMITE_BINARY_URI_FORMAT` is set, it takes precedence over this option. Either method of
    #   setting this option overrides the `github_releases` option.
    #   Example: `https://example.com/download/%{version}/%{filename}`. Replacement variables:
    #     - `filename` - The value of {Config#tarball_filename}
    #     - `version` - the crate version from the `Cargo.toml` file
    # * `cargo_project_path` - the path to the Cargo project. Defaults to the current
    #   working directory.
    # * `cargo_workspace_member` - if set, the relative path to the Cargo workspace member. Usually
    #   used when it is part of a repository containing multiple crates.
    # * `github_releases` - whether to look for rust binaries via GitHub releases when installing
    #   the gem, and `cargo` is not found. Defaults to `false`.
    # * `github_release_type` - when `github_releases` is `true`, the mode to use to download the
    #   Rust binary from GitHub releases. `'cargo'` (the default) uses the version in `Cargo.toml`,
    #   along with the `git_tag_format` option (described below) to determine the download URI.
    #   `'latest'` takes the latest release matching the `git_tag_regex` option (described below) to
    #   determine the download URI.
    # * `git_tag_format` - when `github_release_type` is `'cargo'` (the default), the
    #   [format string](http://ruby-doc.org/core/String.html#method-i-25) used to determine the
    #   tag used in the GitHub download URI. Defaults to `v%s`, where `%s` is the version in
    #   `Cargo.toml`.
    # * `git_tag_regex` - when `github_releases` is enabled and `github_release_type` is
    #   `'latest'`, a regular expression (expressed as a `String`) that determines which tagged
    #   releases to look for precompiled Rust tarballs. One group must be specified that indicates
    #   the version number to be used in the tarball filename. Defaults to the [semantic versioning
    #   2.0.0 format](https://semver.org/spec/v2.0.0.html). In this case, the group is around the
    #   entire expression.
    # * `optional_rust_extension` - prints a warning to STDERR instead of raising an exception, if
    #   Cargo is unavailable and `github_releases` is either disabled or unavailable. Useful for
    #   projects where either fallback code exists, or a native extension is desirable but not
    #   required. Defaults to `false`.
    # * `ruby_project_path` - the toplevel directory of the Ruby gem's project. Defaults to the
    #   current working directory.
    # * `ruby_extension_dir` - the directory relative to `ruby_project_path` where the extension is
    #   located. Defaults to `lib`.
    #
    # These values can be overridden by values with the same key name in the
    # `package.metadata.thermite` section of `Cargo.toml`, if that section exists. The exceptions
    # to this are `cargo_project_path` and `cargo_workspace_member`, since they are both used to
    # find the `Cargo.toml` file.
    #
    attr_reader :options

    #
    # Define the Thermite tasks with the given configuration parameters (see {#options}).
    #
    # Example:
    #
    # ```ruby
    # Thermite::Tasks.new(cargo_project_path: 'rust')
    # ```
    #
    def initialize(options = {})
      @options = options
      @config = Config.new(options)
      @options.merge!(@config.toml_config)
      define_build_task
      define_clean_task
      define_test_task
      define_package_task
    end

    private

    def define_build_task
      desc 'Build or download the Rust shared library: CARGO_PROFILE controls Cargo profile'
      task 'thermite:build' do
        # if cargo found, build. Otherwise, grab binary (when github_releases is enabled).
        if cargo
          profile = ENV.fetch('CARGO_PROFILE', 'release')
          run_cargo_rustc(profile)
          FileUtils.cp(config.cargo_target_path(profile, config.cargo_shared_library),
                       config.ruby_extension_path)
        elsif !download_binary_from_custom_uri && !download_binary_from_github_release
          inform_user_about_cargo
        end
      end
    end

    def define_clean_task
      desc 'Clean up after thermite:build task'
      task 'thermite:clean' do
        FileUtils.rm(config.ruby_extension_path, force: true)
        run_cargo_if_exists 'clean', *cargo_manifest_path_args
      end
    end

    def define_test_task
      desc 'Run Rust testsuite'
      task 'thermite:test' do
        run_cargo_if_exists 'test', *cargo_manifest_path_args
      end
    end

    def define_package_task
      namespace :thermite do
        desc 'Package rust library in a tarball'
        task tarball: %w[thermite:build] do
          build_package
        end
      end
    end
  end
end
