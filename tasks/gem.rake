require 'rubygems/package_task'

gemspec_path = File.join(__dir__, "..", "rake-compiler.gemspec")
gemspec_path = File.expand_path(gemspec_path)
GEM_SPEC = eval(File.read(gemspec_path), TOPLEVEL_BINDING, gemspec_path)

gem_package = Gem::PackageTask.new(GEM_SPEC) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
