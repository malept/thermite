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
require 'uri'

module Thermite
  #
  # Utility methods
  #
  module Util
    #
    # Logs a debug message to the specified `config.debug_filename`, if set.
    #
    def debug(msg)
      # Should probably replace with a Logger
      return unless config.debug_filename

      @debug ||= File.open(config.debug_filename, 'w')
      @debug.write("#{msg}\n")
      @debug.flush
    end

    #
    # Wrapper for a Net::HTTP GET request that handles redirects.
    #
    # :nocov:
    def http_get(uri, retries_left = 10)
      raise RedirectError, 'Too many redirects' if retries_left.zero?

      case (response = Net::HTTP.get_response(URI(uri)))
      when Net::HTTPClientError
        nil
      when Net::HTTPServerError
        raise Net::HTTPServerException.new(response.message, response)
      when Net::HTTPFound, Net::HTTPPermanentRedirect
        http_get(response['location'], retries_left - 1)
      else
        StringIO.new(response.body)
      end
    end
    # :nocov:
  end
end
