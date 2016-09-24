# -*- encoding: utf-8 -*-
# frozen_string_literal: true
#
# Copyright (c) 2016 Mark Lee and contributors
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

require 'net/http'
require 'rexml/document'
require 'uri'

module Thermite
  #
  # GitHub releases binary helpers.
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
    def download_binary
      return false unless options[:github_releases]

      case options[:github_release_type]
      when 'latest'
        download_latest_binary_from_github_release
      else # 'cargo'
        download_cargo_version_from_github_release
      end
    end

    private

    def download_cargo_version_from_github_release
      version = config.toml[:package][:version]
      tag = options.fetch(:git_tag_format, 'v%s') % version
      uri = github_download_uri(tag, version)
      return unless (tgz = download_binary_from_github_release(uri, version))

      debug "Unpacking GitHub release from Cargo version: #{File.basename(uri)}"
      unpack_tarball(tgz)
      true
    end

    #
    # Downloads and unpacks the latest binary from GitHub releases, given the target OS
    # and architecture.
    #
    def download_latest_binary_from_github_release
      installed_binary = false
      each_github_release(github_uri) do |version, download_uri|
        tgz = download_binary_from_github_release(download_uri, version)
        next unless tgz
        debug "Unpacking GitHub release: #{File.basename(download_uri)}"
        unpack_tarball(tgz)
        installed_binary = true
        break
      end

      installed_binary
    end

    def github_uri
      @github_uri ||= config.toml[:package][:repository]
    end

    def github_download_uri(tag, version)
      "#{github_uri}/releases/download/#{tag}/#{config.tarball_filename(version)}"
    end

    # :nocov:
    def http_get(uri)
      Net::HTTP.get(URI(uri))
    end
    # :nocov:

    def each_github_release(github_uri)
      releases_uri = "#{github_uri}/releases.atom"
      feed = REXML::Document.new(http_get(releases_uri))
      REXML::XPath.each(feed, '//entry/title/text()') do |tag|
        match = config.git_tag_regex.match(tag.to_s)
        next unless match
        version = match[1]

        yield(version, github_download_uri(tag, version))
      end
    end

    def download_binary_from_github_release(uri, version)
      case (response = Net::HTTP.get_response(URI(uri)))
      when Net::HTTPClientError
        nil
      when Net::HTTPServerError
        raise Net::HTTPServerException.new(response.message, response)
      else
        unless ENV.key?('THERMITE_TEST')
          # :nocov:
          puts "Downloading latest compiled version (#{version}) from GitHub"
          # :nocov:
        end
        StringIO.new(http_get(response['location']))
      end
    end
  end
end
