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

require 'fiddle'
require 'thermite/config'

module Thermite
  #
  # Fiddle helper functions.
  #
  module Fiddle
    #
    # Loads a native extension using {Thermite::Config} and the builtin `Fiddle` extension.
    #
    # @param init_function_name [String] the name of the native function that initializes
    #                                    the extension
    # @param config_options [Hash] {Thermite::Tasks#options options} passed to {Thermite::Config}.
    #                              Options likely needed to be set:
    #                              `cargo_project_path`, `ruby_project_path`
    #
    def self.load_module(init_function_name, config_options)
      config = Thermite::Config.new(config_options)
      library = ::Fiddle.dlopen(config.ruby_extension_path)
      func = ::Fiddle::Function.new(library[init_function_name],
                                    [], ::Fiddle::TYPE_VOIDP)
      func.call
    end
  end
end
