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

require 'tmpdir'
require 'test_helper'
require 'thermite/custom_binary'
require 'thermite/util'

module Thermite
  class CustomBinaryTest < Minitest::Test
    include Thermite::ModuleTester

    class Tester
      include Thermite::CustomBinary
      include Thermite::TestHelper
      include Thermite::Util
    end

    def test_no_downloading_when_binary_uri_is_falsey
      mock_module(binary_uri_format: false)
      mock_module.expects(:http_get).never

      assert !mock_module.download_binary_from_custom_uri
    end

    def test_download_binary_from_custom_uri
      mock_module(binary_uri_format: 'http://example.com/download/%<version>s/%<filename>s')
      mock_module.config.stubs(:toml).returns(package: { version: '4.5.6' })
      Net::HTTP.stubs(:get_response).returns('location' => 'redirect')
      mock_module.stubs(:http_get).returns('tarball')
      mock_module.expects(:unpack_tarball).once
      mock_module.expects(:prepare_downloaded_library).once

      assert mock_module.download_binary_from_custom_uri
    end

    private

    def described_class
      Tester
    end
  end
end
