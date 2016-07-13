require 'test_helper'
require 'thermite/config'

module Thermite
  class ConfigTest < Minitest::Test
    def test_debug_filename
      assert_nil described_class.new.debug_filename
      ENV['THERMITE_DEBUG_FILENAME'] = 'foo'
      assert_equal 'foo', described_class.new.debug_filename
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

    def test_shared_library
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(false)
      assert_equal 'libfoobar.ext', config.shared_library
    end

    def test_shared_library_windows
      config.stubs(:library_name).returns('foobar')
      config.stubs(:shared_ext).returns('ext')
      Gem.stubs(:win_platform?).returns(true)
      assert_equal 'foobar.ext', config.shared_library
    end

    def test_tarball_filename
      config.stubs(:library_name).returns('foobar')
      config.stubs(:ruby_version).returns('ruby12')
      config.stubs(:target_os).returns('c64')
      config.stubs(:target_arch).returns('z80')
      assert_equal 'foobar-0.1.2-ruby12-c64-z80.tar.gz', config.tarball_filename('0.1.2')
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

    private

    def config(options = {})
      @config ||= described_class.new(options)
    end

    def described_class
      Thermite::Config
    end
  end
end
