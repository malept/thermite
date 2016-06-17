# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rexml/document'
require 'rubygems/package'
require 'uri'
require 'zlib'

module Thermite
  #
  # GitHub releases binary helpers.
  #
  module GithubReleaseBinary
    def http_get(uri)
      Net::HTTP.get(URI(uri))
    end

    def download_latest_binary_from_github_release
      return false unless options[:github_username]
      username = options[:github_username]
      project = options.fetch(:github_repo, library_name)
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

    def each_github_release(github_uri)
      releases_uri = "#{github_uri}/releases.atom"
      feed = REXML::Document.new(http_get(releases_uri))
      REXML::XPath.each(feed, '//entry/title[contains(.,"-rust")]/text()') do |tag|
        version = tag.to_s.slice(1..-6)
        download_uri = "#{github_uri}/releases/download/#{tag}/#{tarball_filename(version)}"

        yield(version, download_uri)
      end
    end

    def download_binary_from_github_release(uri, version)
      case (response = Net::HTTP.get_response(URI(uri)))
      when Net::HTTPClientError
        nil
      when Net::HTTPServerError
        fail response
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
