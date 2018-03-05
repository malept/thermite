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
require 'thermite/github_release_binary'
require 'thermite/util'

module Thermite
  class GithubReleaseBinaryTest < Minitest::Test
    include Thermite::ModuleTester

    class Tester
      include Thermite::GithubReleaseBinary
      include Thermite::TestHelper
      include Thermite::Util
    end

    def test_no_downloading_when_github_releases_is_false
      mock_module(github_releases: false)
      mock_module.expects(:download_latest_binary_from_github_release).never
      mock_module.expects(:download_cargo_version_from_github_release).never

      assert !mock_module.download_binary_from_github_release
    end

    def test_github_release_type_defaults_to_cargo
      mock_module(github_releases: true)
      mock_module.expects(:download_latest_binary_from_github_release).never
      mock_module.expects(:download_cargo_version_from_github_release).once

      mock_module.download_binary_from_github_release
    end

    def test_download_cargo_version_from_github_release
      mock_module(github_releases: true)
      mock_module.config.stubs(:toml).returns(package: { version: '4.5.6' })
      stub_github_download_uri('v4.5.6')
      Net::HTTP.stubs(:get_response).returns('location' => 'redirect')
      mock_module.stubs(:http_get).returns('tarball')
      mock_module.expects(:unpack_tarball).once
      mock_module.expects(:prepare_downloaded_library).once

      assert mock_module.download_binary_from_github_release
    end

    def test_download_cargo_version_from_github_release_with_custom_git_tag_format
      mock_module(github_releases: true, git_tag_format: 'VER_%s')
      mock_module.config.stubs(:toml).returns(package: { version: '4.5.6' })
      stub_github_download_uri('VER_4.5.6')
      Net::HTTP.stubs(:get_response).returns('location' => 'redirect')
      mock_module.stubs(:http_get).returns('tarball')
      mock_module.expects(:unpack_tarball).once
      mock_module.expects(:prepare_downloaded_library).once

      assert mock_module.download_binary_from_github_release
    end

    def test_download_cargo_version_from_github_release_with_no_repository
      mock_module(github_releases: true)
      mock_module.config.stubs(:toml).returns(package: { version: '4.5.6' })

      assert_raises KeyError do
        mock_module.download_binary_from_github_release
      end
    end

    def test_download_cargo_version_from_github_release_with_client_error
      mock_module(github_releases: true)
      mock_module.config.stubs(:toml).returns(
        package: {
          repository: 'test/test',
          version: '4.5.6'
        }
      )
      Net::HTTP.stubs(:get_response).returns(Net::HTTPClientError.new('1.1', 403, 'Forbidden'))

      assert !mock_module.download_binary_from_github_release
    end

    def test_download_cargo_version_from_github_release_with_server_error
      mock_module(github_releases: true)
      mock_module.config.stubs(:toml).returns(
        package: {
          repository: 'test/test',
          version: '4.5.6'
        }
      )
      server_error = Net::HTTPServerError.new('1.1', 500, 'Internal Server Error')
      Net::HTTP.stubs(:get_response).returns(server_error)

      assert_raises Net::HTTPServerException do
        mock_module.download_binary_from_github_release
      end
    end

    def test_download_latest_binary_from_github_release
      mock_module(github_releases: true, github_release_type: 'latest', git_tag_regex: 'v(.*)_rust')
      stub_releases_atom
      mock_module.stubs(:download_versioned_github_release_binary).returns(StringIO.new('tarball'))
      mock_module.expects(:unpack_tarball).once
      mock_module.expects(:prepare_downloaded_library).once

      assert mock_module.download_binary_from_github_release
    end

    def test_download_latest_binary_from_github_release_no_releases_match_regex
      mock_module(github_releases: true, github_release_type: 'latest')
      stub_releases_atom
      mock_module.expects(:github_download_uri).never

      assert !mock_module.download_binary_from_github_release
    end

    def test_download_latest_binary_from_github_release_no_tarball_found
      mock_module(github_releases: true, github_release_type: 'latest', git_tag_regex: 'v(.*)_rust')
      stub_releases_atom
      mock_module.stubs(:download_versioned_github_release_binary).returns(nil)
      mock_module.expects(:unpack_tarball).never
      mock_module.expects(:prepare_downloaded_library).never

      assert !mock_module.download_binary_from_github_release
    end

    private

    def described_class
      Tester
    end

    def stub_github_download_uri(tag)
      uri = 'https://github.com/user/project/downloads/project-4.5.6.tar.gz'
      mock_module.expects(:github_download_uri).with(tag, '4.5.6').returns(uri)
    end

    def stub_releases_atom
      atom = File.read(fixtures_path('github', 'releases.atom'))
      project_uri = 'https://github.com/user/project'
      releases_uri = "#{project_uri}/releases.atom"
      mock_module.config.stubs(:toml).returns(package: { repository: project_uri })
      mock_module.expects(:http_get).with(releases_uri).returns(atom)
    end
  end
end
