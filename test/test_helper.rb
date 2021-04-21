# frozen_string_literal: true
#
# Copyright (c) 2016, 2017 Mark Lee and contributors
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

require 'simplecov'
SimpleCov.start do
  load_profile 'test_frameworks'
  add_filter 'lib/thermite/fiddle.rb'
  add_filter 'lib/thermite/tasks.rb'
  track_files 'lib/**/*.rb'
end

ENV['THERMITE_TEST'] = '1'

require 'minitest/autorun'
require 'mocha/minitest'
require 'thermite/config'

module Minitest
  class Test
    def fixtures_path(*components)
      File.join(File.dirname(__FILE__), 'fixtures', *components)
    end
  end
end

module Thermite
  module ModuleTester
    def mock_module(options = {})
      @mock_module ||= described_class.new(options)
    end
  end

  module TestHelper
    attr_reader :config, :options
    def initialize(options = {})
      @options = options
      @config = Thermite::Config.new(@options)
    end
  end
end
