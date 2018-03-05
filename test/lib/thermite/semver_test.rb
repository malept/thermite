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

require 'thermite/semver'

module Thermite
  class SemVerTest < Minitest::Test
    def test_valid_semantic_versions
      # From https://github.com/malept/thermite/pull/45
      assert semantic_version_regexp.match('0.3.2')
      assert semantic_version_regexp.match('v0.3.2')
      assert semantic_version_regexp.match('0.3.0-rc1')
      assert semantic_version_regexp.match('0.3.0-rc.1')
    end

    def test_invalid_semantic_versions
      # From https://github.com/malept/thermite/pull/45
      assert_nil semantic_version_regexp.match('v0.3.2.beta13')
      assert_nil semantic_version_regexp.match('0.5.3.alpha1')
      assert_nil semantic_version_regexp.match('0.5.3.1')
    end

    def test_valid_semantic_prerelease_versions
      # From https://semver.org/spec/v2.0.0.html#spec-item-9
      assert semantic_version_regexp.match('1.0.0-alpha')
      assert semantic_version_regexp.match('1.0.0-alpha.1')
      assert semantic_version_regexp.match('1.0.0-0.3.7')
      assert semantic_version_regexp.match('1.0.0-x.7.z.92')
    end

    def test_valid_semantic_build_metadata_versions
      # From https://semver.org/spec/v2.0.0.html#spec-item-10
      assert semantic_version_regexp.match('1.0.0-alpha+001')
      assert semantic_version_regexp.match('1.0.0+20130313144700')
      assert semantic_version_regexp.match('1.0.0-beta+exp.sha.5114f85')
    end

    def semantic_version_regexp
      @semantic_version_regexp ||= /^#{Thermite::SemVer::VERSION}$/
    end
  end
end
