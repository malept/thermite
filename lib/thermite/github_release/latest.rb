
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

require 'rexml/document'
require 'thermite/github_release/base'

module Thermite
  module GithubRelease
    #
    # Downloads and unpacks the latest binary tarball from GitHub releases, given the target OS
    # and architecture.
    #
    class Latest < Base
      #
      # Iterates through each GitHub release in descending chronological order to find the first
      # binary corresponding to the OS, architecture, and Ruby version.
      #
      def download_binary
        tgz = nil
        each_github_release(github_uri) do |version, download_uri|
          next unless (tgz = download_versioned_github_release_binary(download_uri, version))
          tasks.debug "Unpacking GitHub release: #{File.basename(download_uri)}"
          break
        end

        tgz
      end

      private

      def each_github_release(github_uri)
        releases_uri = "#{github_uri}/releases.atom"
        feed = REXML::Document.new(tasks.http_get(releases_uri))
        REXML::XPath.each(feed, '//entry/title/text()') do |tag|
          match = tasks.config.git_tag_regex.match(tag.to_s)
          next unless match
          version = match[1]

          yield(version, github_download_uri(tag, version))
        end
      end
    end
  end
end
