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
require 'rubygems/package'
require 'uri'
require 'zlib'

module Thermite
  #
  # GitHub releases binary helpers.
  #
  module GithubReleaseBinary
    #
    # Downloads and unpacks the latest binary from GitHub releases, given the target OS
    # and architecture.
    #
    # Requires the `github_username` option to be set. The project name defaults to using the
    # `library_name`, but is configurable via the `github_repo` option.
    #
    # Returns whether a binary was found and unpacked.
    #
    def download_latest_binary_from_github_release
      return false unless options[:github_username]
      username = options[:github_username]
      project = options.fetch(:github_repo, config.library_name)
      installed_binary = false
      github_uri = "https://github.com/#{username}/#{project}"
      each_github_release(github_uri) do |version, download_uri|
        tgz = download_binary_from_github_release(download_uri, version)
        next unless tgz
        unpack_tarball(tgz)
        installed_binary = true
        break
      end

      installed_binary
    end

    private

    def http_get(uri)
      Net::HTTP.get(URI(uri))
    end

    def each_github_release(github_uri)
      releases_uri = "#{github_uri}/releases.atom"
      feed = REXML::Document.new(http_get(releases_uri))
      REXML::XPath.each(feed, '//entry/title[contains(.,"-rust")]/text()') do |tag|
        version = tag.to_s.slice(1..-6)
        download_uri = "#{github_uri}/releases/download/#{tag}/#{config.tarball_filename(version)}"

        yield(version, download_uri)
      end
    end

    def download_binary_from_github_release(uri, version)
      case (response = Net::HTTP.get_response(URI(uri)))
      when Net::HTTPClientError
        nil
      when Net::HTTPServerError
        raise response
      else
        puts "Downloading latest compiled version (#{version}) from GitHub"
        StringIO.new(http_get(response['location']))
      end
    end

    def unpack_tarball(tgz)
      gz = Zlib::GzipReader.new(tgz)
      tar = Gem::Package::TarReader.new(gz)
      tar.each do |entry|
        path = entry.header.name
        next if path.end_with?('/')
        File.open(path, 'wb') do |f|
          f.write(entry.read)
        end
      end
    end
  end
end
