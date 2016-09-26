if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    load_profile 'test_frameworks'
    add_filter 'lib/thermite/fiddle.rb'
    add_filter 'lib/thermite/tasks.rb'
    track_files 'lib/**/*.rb'
  end
end

ENV['THERMITE_TEST'] = '1'

require 'minitest/autorun'
require 'mocha/mini_test'
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
