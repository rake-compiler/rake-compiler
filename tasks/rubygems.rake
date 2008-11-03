require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  # basic information
  s.name        = "rake-compiler"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY

  # description and details
  s.summary     = 'Rake-based Ruby C Extension task generator.'
  s.description = <<-EOF
    Provide a spandard and simplified way to build and package
    Ruby C extensions using Rake as glue.
  EOF

  # dependencies
  s.add_dependency  'rake', '>= 0.8.3', '~> 0.8.4'

  # development dependencies
  #s.add_development_dependency 'rspec', '~> 1.1.9'
  #s.add_development_dependency 'cucumber', '~> 0.1.8'

  # components, files and paths
  #s.files
  s.require_path = 'lib'

  # documentation
  s.has_rdoc = false

  # project information
  s.homepage    = 'TODO'
  s.rubyforge_project = 'TODO'

  # author and contributors
  s.author      = 'Luis Lavena'
  s.email       = 'luislavena@gmail.com'
end

gem_package = Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end

file 'rake-compiler.gemspec' => ['Rakefile', 'tasks/rubygems.rake'] do |t|
  File.open(t.name, 'w') { |f| f.puts spec.to_yaml }
end

desc "Generate or update the standalone gemspec file for the project"
task :gemspec => ['rake-compiler.gemspec']
