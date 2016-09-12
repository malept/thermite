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
      mock_module.expects(:sh).with('/opt/cargo-test/bin/cargo foo bar').once
      mock_module.run_cargo_if_exists('foo', 'bar')
    end

    def test_run_cargo_if_exists_sans_cargo
      mock_module.stubs(:find_executable).returns(nil)
      mock_module.expects(:sh).never
      mock_module.run_cargo_if_exists('foo', 'bar')
    end

    def test_run_cargo_debug_build
      mock_module.expects(:run_cargo).with('build').once
      mock_module.run_cargo_build('debug')
    end

    def test_run_cargo_release_build
      mock_module.expects(:run_cargo).with('build', '--release').once
      mock_module.run_cargo_build('release')
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
