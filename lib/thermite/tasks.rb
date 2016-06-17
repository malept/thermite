# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'fileutils'
# Defined here instead of in thermite/package because otherwise a weird FFI exception occurs
require 'fpm'
require 'rake/tasklib'
require 'thermite/cargo'
require 'thermite/config'
require 'thermite/github_release_binary'
require 'thermite/package'

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
    include Thermite::Config
    include Thermite::GithubReleaseBinary
    include Thermite::Package

    attr_reader :options

    def initialize(options = {})
      @options = options
      define_build_task
      define_clean_task
      define_test_task
      define_package_task
    end

    def define_build_task
      desc 'Build or download the Rust shared library: TARGET controls Cargo target'
      task 'thermite:build' do
        # if cargo found, build. Otherwise, grab binary.
        if cargo
          target = ENV.fetch('TARGET', 'release')
          cargo_args = %w(build)
          cargo_args << '--release' if target == 'release'
          run_cargo cargo_args
          FileUtils.cp "target/#{target}/#{shared_library}", 'lib/'
        elsif !download_latest_binary_from_github_release
          fail cargo_required_msg
        end
      end
    end

    def define_clean_task
      desc 'Clean up after thermite:build task'
      task 'thermite:clean' do
        FileUtils.rm "lib/#{shared_library}", force: true
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
