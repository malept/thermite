module Thermite
  #
  # Helpers to package the Rust library
  #
  module Package
    def build_package
      dir = FPM::Package::Dir.new
      dir.input("lib/#{shared_library}")
      tarball = dir.convert(FPM::Package::Tar)
      tarball.name = library_name
      tarball.output(tarball_filename(toml[:package][:version]))
    end
  end
end
