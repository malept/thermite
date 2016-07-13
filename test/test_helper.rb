if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    load_profile 'test_frameworks'
    add_filter 'lib/thermite/tasks.rb'
    track_files 'lib/**/*.rb'
  end
end

require 'minitest/autorun'
require 'mocha/mini_test'

module Minitest
  class Test
    def fixtures_path(*components)
      File.join(File.dirname(__FILE__), 'fixtures', *components)
    end
  end
end
