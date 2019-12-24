# -*- ruby -*-

Gem::Specification.new do |s|
  # basic information
  s.name        = "rake-compiler"
  s.version     = "1.1.1"
  s.platform    = Gem::Platform::RUBY

  # description and details
  s.summary     = 'Rake-based Ruby Extension (C, Java) task generator.'
  s.description = "Provide a standard and simplified way to build and package\nRuby extensions (C, Java) using Rake as glue."

  # requirements
  s.required_ruby_version = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.8.23"

  # dependencies
  s.add_dependency  'rake'

  # development dependencies
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'cucumber', '~> 1.1.4'

  # components, files and paths
  s.files = Dir.glob("features/**/*.{feature,rb}")
  s.files += ["bin/rake-compiler"]
  s.files += Dir.glob("lib/**/*.rb")
  s.files += ["spec/spec.opts"]
  s.files += Dir.glob("spec/**/*.rb")
  s.files += Dir.glob("tasks/**/*.rake")
  s.files += ["Rakefile", "Gemfile"]
  s.files += Dir.glob("*.{md,rdoc,txt,yml}")

  s.bindir      = 'bin'
  s.executables = ['rake-compiler']

  s.require_path = 'lib'

  # documentation
  s.rdoc_options << '--main'  << 'README.md' << '--title' << 'rake-compiler -- Documentation'

  s.extra_rdoc_files = %w(README.md LICENSE.txt History.txt)

  # project information
  s.homepage          = 'https://github.com/rake-compiler/rake-compiler'
  s.licenses          = ['MIT']

  # author and contributors
  s.authors     = ['Kouhei Sutou', 'Luis Lavena']
  s.email       = ['kou@cozmixng.org', 'luislavena@gmail.com']
end
