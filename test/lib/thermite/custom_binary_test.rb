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
      mock_module(binary_uri_format: 'http://example.com/download/%{version}/%{filename}')
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
