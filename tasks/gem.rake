require 'rubygems/package_task'

GEM_SPEC = Gem::Specification.new do |s|
  # basic information
  s.name        = "rake-compiler"
  s.version     = "0.7.0"
  s.platform    = Gem::Platform::RUBY

  # description and details
  s.summary     = 'Rake-based Ruby Extension (C, Java) task generator.'
  s.description = "Provide a standard and simplified way to build and package\nRuby extensions (C, Java) using Rake as glue."

  # requirements
  s.required_ruby_version = ">= 1.8.6"
  s.required_rubygems_version = ">= 1.3.5"

  # dependencies
  s.add_dependency  'rake', '>= 0.8.3', '< 0.9'

  # development dependencies
  s.add_development_dependency 'rspec', '~> 1.2.9'
  s.add_development_dependency 'cucumber', '~> 0.4.4'
  #s.add_development_dependency 'rcov', '~> 0.9.6'

  # components, files and paths
  s.files = FileList["features/**/*.{feature,rb}", "bin/rake-compiler",
                      "lib/**/*.rb", "spec/**/*.rb", "tasks/**/*.rake",
                      "Rakefile", "*.{rdoc,txt,yml}"]

  s.bindir      = 'bin'
  s.executables = ['rake-compiler']

  s.require_path = 'lib'

  # documentation
  s.has_rdoc = true
  s.rdoc_options << '--main'  << 'README.rdoc' << '--title' << 'rake-compiler -- Documentation'

  s.extra_rdoc_files = %w(README.rdoc LICENSE.txt History.txt)

  # project information
  s.homepage          = 'http://github.com/luislavena/rake-compiler'
  s.rubyforge_project = 'rake-compiler'
  s.licenses          = ['MIT']

  # author and contributors
  s.author      = 'Luis Lavena'
  s.email       = 'luislavena@gmail.com'
end

gem_package = Gem::PackageTask.new(GEM_SPEC) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
