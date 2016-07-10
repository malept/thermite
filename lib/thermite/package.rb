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

require 'archive/tar/minitar'
require 'zlib'

module Thermite
  #
  # Helpers to package the Rust library, using FPM.
  #
  module Package
    #
    # Builds a tarball of the Rust-compiled shared library.
    #
    def build_package
      filename = config.tarball_filename(config.toml[:package][:version])
      tgz = Zlib::GzipWriter.new(File.open(filename, 'wb'))
      relative_library_path = config.ruby_extension_path.sub("#{config.ruby_toplevel_dir}/", '')
      Dir.chdir(config.ruby_toplevel_dir) do
        Archive::Tar::Minitar.pack(relative_library_path, tgz)
      end
    end
  end
end
