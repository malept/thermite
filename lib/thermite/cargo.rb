# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'mkmf'

module Thermite
  #
  # Cargo helpers
  #
  module Cargo
    def cargo
      @cargo ||= find_executable(ENV.fetch('CARGO', 'cargo'))
    end

    def run_cargo(*args)
      sh "#{cargo} #{args.join(' ')}"
    end

    def run_cargo_if_exists(*args)
      run_cargo(*args) if cargo
    end

    def cargo_required_msg
      <<EOM
****
Rust's Cargo is required to build this extension. Please install Rust and put
it in the PATH, or set the CARGO environment variable appropriately.
****
EOM
    end
  end
end
