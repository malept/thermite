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

module Thermite
  class ConfigTest < Minitest::Test
    def test_debug_filename
      assert_nil described_class.new.debug_filename
      ENV['THERMITE_DEBUG_FILENAME'] = 'foo'
      assert_equal 'foo', described_class.new.debug_filename
      ENV['THERMITE_DEBUG_FILENAME'] = nil
    end

    def test_shared_ext_osx
      config.stubs(:dlext).returns('bundle')
      assert_equal 'dylib', config.shared_ext
    end

    def test_shared_ext_windows
      config.stubs(:dlext).returns('so')
      Gem.stubs(:win_platform?).returns(true)
      assert_equal 'dll', config.shared_ext
    end

    def test_shared_ext_unix
      config.stubs(:dlext).returns('foobar')
      Gem.stubs(:win_platform?).returns(false)
      assert_equal 'foobar', config.shared_ext
    end

    def test_ruby_version
      config.stubs(:rbconfig_ruby_version).returns('3.2.0')
      assert_equal 'ruby32', config.ruby_version
    end

    def test_library_name_from_cargo_lib
      config.stubs(:toml).returns(lib: { name: 'foobar' }, package: { name: 'barbaz' })
      assert_equal 'foobar', config.library_name
    end

    def test_library_name_from_cargo_package
      config.stubs(:toml).returns(lib: {}, package: { name: 'barbaz' })
      assert_equal 'barbaz', config.library_name
    end

    def test_library_name_from_cargo_lib_has_no_hyphens
      config.stubs(:toml).returns(lib: { name: 'foo-bar' }, package: { name: 'bar-baz' })
      assert_equal 'foo_bar', config.library_name
    end

    def test_library_name_from_cargo_package_has_no_hyphens
      config.stubs(:toml).returns(lib: {}, package: { name: 'bar-baz' })
      assert_equal 'bar_baz', config.library_name
    end

    def test_shared_library
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(false)
      assert_equal 'foobar.so', config.shared_library
    end

    def test_shared_library_windows
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(true)
      assert_equal 'foobar.so', config.shared_library
    end

    def test_cargo_shared_library
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(false)
      assert_equal 'libfoobar.ext', config.cargo_shared_library
    end

    def test_cargo_shared_library_windows
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(true)
      assert_equal 'foobar.ext', config.cargo_shared_library
    end

    def test_tarball_filename
      stub_tarball_filename_params(false)
      assert_equal 'foobar-0.1.2-ruby12-c64-z80.tar.gz', config.tarball_filename('0.1.2')
    end

    def test_tarball_filename_with_static_extension
      stub_tarball_filename_params(true)
      assert_equal 'foobar-0.1.2-ruby12-c64-z80-static.tar.gz', config.tarball_filename('0.1.2')
    end

    def test_default_ruby_toplevel_dir
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/foobar', config.ruby_toplevel_dir
    end

    def test_ruby_toplevel_dir
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/barbaz', config(ruby_project_path: '/tmp/barbaz').ruby_toplevel_dir
    end

    def test_ruby_path
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/foobar/baz/quux', config.ruby_path('baz', 'quux')
    end

    def test_ruby_extension_path
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      config.stubs(:shared_library).returns('libfoo.ext')
      assert_equal '/tmp/foobar/lib/libfoo.ext', config.ruby_extension_path
    end

    def test_ruby_extension_path_with_custom_extension_dir
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      config.stubs(:ruby_extension_dir).returns('lib/ext')
      config.stubs(:shared_library).returns('libfoo.ext')
      assert_equal '/tmp/foobar/lib/ext/libfoo.ext', config.ruby_extension_path
    end

    def test_default_rust_toplevel_dir
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/foobar', config.rust_toplevel_dir
    end

    def test_rust_toplevel_dir
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/barbaz', config(cargo_project_path: '/tmp/barbaz').rust_toplevel_dir
    end

    def test_rust_path
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      assert_equal '/tmp/foobar/baz/quux', config.rust_path('baz', 'quux')
    end

    def test_cargo_target_path_with_env_var
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      ENV['CARGO_TARGET_DIR'] = 'foo'
      assert_equal File.join('foo', 'debug', 'bar'), config.cargo_target_path('debug', 'bar')
      ENV['CARGO_TARGET_DIR'] = nil
    end

    def test_cargo_target_path_without_env_var
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      ENV['CARGO_TARGET_DIR'] = nil
      assert_equal File.join('/tmp/foobar', 'target', 'debug', 'bar'),
                   config.cargo_target_path('debug', 'bar')
    end

    def test_cargo_toml_path_with_workspace_member
      FileUtils.stubs(:pwd).returns('/tmp/foobar')
      config(cargo_workspace_member: 'baz')
      assert_equal '/tmp/foobar/baz/Cargo.toml', config.cargo_toml_path
    end

    def test_default_git_tag_regex
      assert_equal described_class::DEFAULT_TAG_REGEX, config.git_tag_regex
    end

    def test_git_tag_regex
      assert_equal(/abc(\d)/, config(git_tag_regex: 'abc(\d)').git_tag_regex)
    end

    def test_toml
      expected = {
        package: {
          name: 'fixture',
          metadata: {
            thermite: {
              github_releases: true
            }
          }
        }
      }
      assert_equal expected, config(cargo_project_path: fixtures_path('config')).toml
    end

    def test_default_toml_config
      config.stubs(:toml).returns({})
      assert_equal({}, config.toml_config)
    end

    def test_toml_config
      expected = { github_releases: true }
      assert_equal expected, config(cargo_project_path: fixtures_path('config')).toml_config
    end

    def test_static_extension_sans_env_var
      ENV.stubs(:key?).with('RUBY_STATIC').returns(false)
      RbConfig::CONFIG.stubs(:[]).with('ENABLE_SHARED').returns('yes')
      refute config.static_extension?

      RbConfig::CONFIG.stubs(:[]).with('ENABLE_SHARED').returns('no')
      assert config.static_extension?
    end

    def test_static_extension_with_env_var
      ENV.stubs(:key?).with('RUBY_STATIC').returns(true)
      RbConfig::CONFIG.stubs(:[]).with('ENABLE_SHARED').returns('yes')
      assert config.static_extension?
    end

    private

    def config(options = {})
      @config ||= described_class.new(options)
    end

    def described_class
      Thermite::Config
    end

    def stub_tarball_filename_params(static_extension)
      config.stubs(:library_name).returns('foobar')
      config.stubs(:ruby_version).returns('ruby12')
      config.stubs(:target_os).returns('c64')
      config.stubs(:target_arch).returns('z80')
      config.stubs(:static_extension?).returns(static_extension)
    end
  end
end
