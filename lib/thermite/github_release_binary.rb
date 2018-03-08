# frozen_string_literal: true
#
# Copyright (c) 2016, 2017, 2018 Mark Lee and contributors
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

require 'thermite/github_release/cargo'
require 'thermite/github_release/latest'

module Thermite
  #
  # GitHub releases binary helpers.
  #
  # Depends on {#Thermite::Package}.
  #
  module GithubReleaseBinary
    #
    # Downloads a Rust binary from GitHub releases, given the target OS and architecture.
    #
    # Requires the `github_releases` option to be `true`. It uses the `repository` value in the
    # project's `Cargo.toml` (in the `package` section) to determine where the releases
    # are located.
    #
    # If the `github_release_type` is `'latest'`, it will attempt to use the appropriate binary for
    # the latest version in GitHub releases. Otherwise, it will download the appropriate binary for
    # the crate version given in `Cargo.toml`.
    #
    # Returns whether a binary was found and unpacked.
    #
    def download_binary_from_github_release
      return false unless options[:github_releases]

      begin
        release_type = (options[:github_release_type] || 'cargo').capitalize
        release_class = Thermite::GithubRelease.const_get(release_type)
      rescue NameError
        raise "Cannot find 'Thermite::GitHubRelease::#{release_type}', " \
              "'#{options[:github_release_type]}' is not a known release type"
      end

      return false unless (tgz = release_class.new(self).download_binary)

      unpack_tarball(tgz)
      prepare_downloaded_library
      true
    end
  end
end
