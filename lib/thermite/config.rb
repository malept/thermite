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
