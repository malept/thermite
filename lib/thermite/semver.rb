# frozen_string_literal: true
#
# Copyright (c) 2018 Mark Lee and contributors
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
  # [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (2.0.0) regular expression.
  #
  module SemVer
    #
    # Valid version number part (major/minor/patch).
    #
    NUMERIC = '(?:0|[1-9]\d*)'.freeze

    #
    # Valid identifier for pre-release versions or build metadata.
    #
    IDENTIFIER = '[-0-9A-Za-z][-0-9A-Za-z.]*'.freeze

    #
    # Version pre-release section, including the hyphen.
    #
    PRERELEASE = "-#{IDENTIFIER}".freeze

    #
    # Version build metadata section, including the plus sign.
    #
    BUILD_METADATA = "\\+#{IDENTIFIER}".freeze

    #
    # Semantic version-compliant regular expression.
    #
    VERSION = "v?#{NUMERIC}\.#{NUMERIC}\.#{NUMERIC}(?:#{PRERELEASE})?(?:#{BUILD_METADATA})?".freeze
  end
end
