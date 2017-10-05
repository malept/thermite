# frozen_string_literal: true
#
# Copyright (c) 2016, 2017 Mark Lee and contributors
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

require 'test_helper'
require 'thermite/cargo'

module Thermite
  class CargoTest < Minitest::Test
    include Thermite::ModuleTester

    class Tester
      include Thermite::Cargo
      include Thermite::TestHelper
    end

    def test_run_cargo_if_exists
      mock_module.stubs(:find_executable).returns('/opt/cargo-test/bin/cargo')
      mock_module.expects(:sh).with('/opt/cargo-test/bin/cargo', 'foo', 'bar').once
      mock_module.run_cargo_if_exists('foo', 'bar')
    end

    def test_run_cargo_if_exists_sans_cargo
      mock_module.stubs(:find_executable).returns(nil)
      mock_module.expects(:sh).never
      mock_module.run_cargo_if_exists('foo', 'bar')
    end

    def test_run_cargo_debug_rustc
      mock_module.config.stubs(:dynamic_linker_flags).returns('')
      mock_module.expects(:run_cargo).with('rustc').once
      mock_module.run_cargo_rustc('debug')
    end

    def test_run_cargo_release_rustc
      mock_module.config.stubs(:dynamic_linker_flags).returns('')
      mock_module.expects(:run_cargo).with('rustc', '--release').once
      mock_module.run_cargo_rustc('release')
    end

    def test_run_cargo_rustc_with_workspace_member
      mock_module.config.stubs(:dynamic_linker_flags).returns('')
      mock_module.config.stubs(:cargo_workspace_member).returns('foo/bar')
      mock_module.expects(:run_cargo).with('rustc', '--manifest-path', 'foo/bar/Cargo.toml').once
      mock_module.run_cargo_rustc('debug')
    end

    def test_run_cargo_rustc_with_dynamic_linker_flags
      mock_module.config.stubs(:dynamic_linker_flags).returns('foo bar')
      if RbConfig::CONFIG['target_os'] == 'mingw32'
        mock_module.expects(:run_cargo).with('rustc').once
      else
        mock_module.expects(:run_cargo).with('rustc', '--lib', '--', '-C', 'link-args=foo bar').once
      end
      mock_module.run_cargo_rustc('debug')
    end

    def test_inform_user_about_cargo_exception
      _, err = capture_io do
        assert_raises RuntimeError do
          mock_module(optional_rust_extension: false).inform_user_about_cargo
        end
      end

      assert_equal '', err
    end

    def test_inform_user_about_cargo_warning
      _, err = capture_io do
        mock_module(optional_rust_extension: true).inform_user_about_cargo
      end

      assert_equal mock_module.cargo_recommended_msg, err
    end

    def described_class
      Tester
    end
  end
end
