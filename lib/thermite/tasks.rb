# -*- encoding: utf-8 -*-
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
    include Thermite::GithubReleaseBinary
    include Thermite::Package
    include Thermite::Util

    #
    # The configuration used for the Rake tasks.
    #
    attr_reader :config

    #
    # Possible configuration options for Thermite tasks:
    #
    # * `cargo_project_path` - the path to the Cargo project. Defaults to the current
    #   working directory.
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
    #   the version number to be used in the tarball filename. Defaults to `vN.N.N`, where `N` is
    #   any n-digit number. In this case, the group is around the entire expression.
    # * `ruby_project_path` - the toplevel directory of the Ruby gem's project. Defaults to the
    #   current working directory.
    #
    # These values can be overridden by values with the same key name in the
    # `package.metadata.thermite` section of `Cargo.toml`, if that section exists.
    #
    attr_reader :options

    #
    # Define the Thermite tasks with the given configuration parameters (see `options`).
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
      define_build_optional_task
      define_clean_task
      define_test_task
      define_package_task
    end

    private

    def define_build_task
      desc 'Build or download the Rust shared library: CARGO_TARGET controls Cargo target'
      task 'thermite:build' do
        # if cargo found, build. Otherwise, grab binary (when github_releases is enabled).
        if cargo
          target = ENV.fetch('CARGO_TARGET', 'release')
          run_cargo_build(target)
          FileUtils.cp(config.rust_path('target', target, config.shared_library),
                       config.ruby_path('lib'))
        elsif !download_binary
          raise cargo_required_msg
        end
      end
    end

    def define_build_optional_task
      desc 'Like thermite:build, but will not fail if Rust or download is unavailable.'
      task 'thermite:build:optional' do
        # if cargo found, build. Otherwise, grab binary (when github_releases is enabled).
        if cargo
          target = ENV.fetch('CARGO_TARGET', 'release')
          run_cargo_build(target)
          FileUtils.cp(config.rust_path('target', target, config.shared_library),
                       config.ruby_path('lib'))
        elsif !download_binary
          puts cargo_not_found_msg
        end
      end
    end

    def define_clean_task
      desc 'Clean up after thermite:build task'
      task 'thermite:clean' do
        FileUtils.rm(config.ruby_extension_path, force: true)
        run_cargo_if_exists 'clean'
      end
    end

    def define_test_task
      desc 'Run Rust testsuite'
      task 'thermite:test' do
        run_cargo_if_exists 'test'
      end
    end

    def define_package_task
      namespace :thermite do
        desc 'Package rust library in a tarball'
        task tarball: %w(thermite:build) do
          build_package
        end
      end
    end
  end
end
