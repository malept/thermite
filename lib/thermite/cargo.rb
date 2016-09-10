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

require 'mkmf'
require 'shellwords'

module Thermite
  #
  # Cargo helpers
  #
  module Cargo
    #
    # Path to `cargo`. Can be overwritten by using the `CARGO` environment variable.
    #
    def cargo
      @cargo ||= find_executable(ENV.fetch('CARGO', 'cargo'))
    end

    #
    # Run `cargo` with the given `args` and return `STDOUT`.
    #
    def run_cargo(*args)
      Dir.chdir(config.rust_toplevel_dir) do
        sh "#{cargo} #{Shellwords.join(args)}"
      end
    end

    #
    # Only `run_cargo` if it is found in the executable paths.
    #
    def run_cargo_if_exists(*args)
      run_cargo(*args) if cargo
    end

    #
    # Run `cargo build`, given a target (i.e., `release` [default] or `debug`).
    #
    def run_cargo_build(target)
      cargo_args = %w(build)
      cargo_args << '--release' if target == 'release'
      run_cargo(*cargo_args)
    end

    # :nocov:

    #
    # Message used when cargo is required but not found.
    #
    def cargo_required_msg
      <<EOM
****
Rust's Cargo is required to build this extension. Please install Rust and put
it in the PATH, or set the CARGO environment variable appropriately.
****
EOM
    end
  end
end
