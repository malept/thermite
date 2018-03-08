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

require 'thermite/github_release/base'

module Thermite
  module GithubRelease
    #
    # Downloads and unpacks a binary tarball from GitHub releases, given the version in
    # `Cargo.toml`, the target OS, and target architecture.
    #
    class Cargo < Base
      #
      # Utilizes the `git_tag_format` option to generate the GitHub release URI.
      #
      def download_binary
        version = tasks.config.crate_version
        # TODO: Change this to a named token and increment the 0.minor version
        # rubocop:disable Style/FormatStringToken
        tag = tasks.options.fetch(:git_tag_format, 'v%s') % version
        # rubocop:enable Style/FormatStringToken
        uri = github_download_uri(tag, version)
        return unless (tgz = download_versioned_github_release_binary(uri, version))

        tasks.debug "Unpacking GitHub release from Cargo version: #{File.basename(uri)}"
        tgz
      end
    end
  end
end
