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

require 'rbconfig'
require 'tomlrb'

module Thermite
  #
  # Configuration helpers
  #
  module Config
    def shared_ext
      @shared_ext ||= RbConfig::CONFIG['DLEXT'] == 'bundle' ? 'dylib' : RbConfig::CONFIG['DLEXT']
    end

    def target_os
      @target_os ||= RbConfig::CONFIG['target_os']
    end

    def target_arch
      @target_arch ||= RbConfig::CONFIG['target_cpu']
    end

    def library_name
      @library_name ||= begin
        if toml[:lib] && toml[:lib][:name]
          toml[:lib][:name]
        else
          toml[:package][:name]
        end
      end
    end

    def shared_library
      "lib#{library_name}.#{shared_ext}"
    end

    def tarball_filename(version)
      "#{library_name}-#{version}-#{target_os}-#{target_arch}.tar.gz"
    end

    def toml
      @toml ||= begin
        project_path = options.fetch(:cargo_project_path, FileUtils.pwd)
        toml_path = File.join(project_path, 'Cargo.toml')
        Tomlrb.load_file(toml_path, symbolize_keys: true)
      end
    end
  end
end
