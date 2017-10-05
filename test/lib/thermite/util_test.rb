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
      mock_module.debug('will not exist')
      debug_file = Tempfile.new('thermite_test')
      stub_debug_filename(debug_file.path)
      mock_module.debug('some message')
      mock_module.instance_variable_get('@debug').flush
      debug_file.rewind
      assert_equal "some message\n", debug_file.read
    ensure
      debug_file.close
      debug_file.unlink
    end

    def stub_debug_filename(value)
      mock_module.config.stubs(:debug_filename).returns(value)
    end

    def described_class
      Tester
    end
  end
end
