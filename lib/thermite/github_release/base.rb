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

module Thermite
  #
  # Namespace for downloading binaries from a GitHub release.
  #
  module GithubRelease
    #
    # Base class for downloading a Rust binary from a GitHub release.
    #
    # Subclasses MUST implement {#download_binary} in order to function.
    #
    class Base
      #
      # The instance of {#Thermite::Tasks} that created this instance.
      #
      attr_reader :tasks

      #
      # Creates a new object with a reference to a {#Thermite::Tasks} instance.
      #
      def initialize(tasks)
        @tasks = tasks
      end

      #
      # Downloads the binary.
      # @return [IO] if a binary was found and downloaded
      #
      def download_binary
        # :nocov:
        raise NotImplementedError, "#{self.class.name} must implement download_binary"
        # :nocov:
      end

      protected

      #
      # The URI of the GitHub repository.
      #
      def github_uri
        @github_uri ||= begin
          unless (repository = tasks.config.toml[:package][:repository])
            raise KeyError, 'No repository found in Config.toml'
          end

          repository
        end
      end

      #
      # The URI of the binary in the GitHub release, given a tag and a version.
      #
      def github_download_uri(tag, version)
        "#{github_uri}/releases/download/#{tag}/#{tasks.config.tarball_filename(version)}"
      end

      #
      # Wrapper to download a binary from a GitHub release.
      #
      def download_versioned_github_release_binary(uri, version)
        unless ENV.key?('THERMITE_TEST')
          # :nocov:
          puts "Downloading compiled version (#{version}) from GitHub"
          # :nocov:
        end

        tasks.http_get(uri)
      end
    end
  end
end
