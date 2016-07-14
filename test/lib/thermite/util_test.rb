require 'tempfile'
require 'test_helper'
require 'thermite/util'

module Thermite
  class UtilTest < Minitest::Test
    include Thermite::ModuleTester

    class Tester
      include Thermite::TestHelper
      include Thermite::Util
    end

    def test_debug
      stub_debug_filename(nil)
      test_helper.debug('will not exist')
      debug_file = Tempfile.new('thermite_test')
      stub_debug_filename(debug_file.path)
      test_helper.debug('some message')
      test_helper.instance_variable_get('@debug').flush
      debug_file.rewind
      assert_equal "some message\n", debug_file.read
    ensure
      debug_file.close
      debug_file.unlink
    end

    def stub_debug_filename(value)
      test_helper.config.stubs(:debug_filename).returns(value)
    end

    def described_class
      Tester
    end
  end
end
