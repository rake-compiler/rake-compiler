--- !ruby/object:Gem::Specification 
name: rake-compiler
version: !ruby/object:Gem::Version 
  version: 0.5.0
platform: ruby
authors: 
- Luis Lavena
autorequire: 
bindir: bin
cert_chain: []

date: 2009-04-25 00:00:00 -03:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: rake
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 0.8.3
    - - <
      - !ruby/object:Gem::Version 
        version: "0.9"
    version: 
description: |-
  Provide a standard and simplified way to build and package
  Ruby C extensions using Rake as glue.
email: luislavena@gmail.com
executables: 
- rake-compiler
extensions: []

extra_rdoc_files: 
- README.rdoc
- LICENSE.txt
- History.txt
files: 
- features/compile.feature
- features/cross-compile.feature
- features/cross-package-multi.feature
- features/cross-package.feature
- features/package.feature
- features/step_definitions/compilation.rb
- features/step_definitions/cross_compilation.rb
- features/step_definitions/execution.rb
- features/step_definitions/folders.rb
- features/step_definitions/gem.rb
- features/support/env.rb
- features/support/file_template_helpers.rb
- features/support/generator_helpers.rb
- bin/rake-compiler
- lib/rake/extensioncompiler.rb
- lib/rake/extensiontask.rb
- spec/lib/rake/extensiontask_spec.rb
- spec/spec_helper.rb
- spec/support/capture_output_helper.rb
- tasks/bin/cross-ruby.rake
- tasks/common.rake
- tasks/cucumber.rake
- tasks/gem.rake
- tasks/news.rake
- tasks/rdoc.rake
- tasks/rdoc_publish.rake
- tasks/release.rake
- tasks/rspec.rake
- Rakefile
- README.rdoc
- History.txt
- LICENSE.txt
- cucumber.yml
has_rdoc: true
homepage: http://github.com/luislavena/rake-compiler
licenses: 
- MIT
post_install_message: 
rdoc_options: 
- --main
- README.rdoc
- --title
- rake-compiler -- Documentation
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: rake-compiler
rubygems_version: 1.3.2
signing_key: 
specification_version: 3
summary: Rake-based Ruby C Extension task generator.
test_files: []

