--- !ruby/object:Gem::Specification 
name: rake-compiler
version: !ruby/object:Gem::Version 
  version: 0.2.1
platform: ruby
authors: 
- Luis Lavena
autorequire: 
bindir: bin
cert_chain: []

date: 2008-11-30 00:00:00 -05:00
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
description: Provide a standard and simplified way to build and package Ruby C extensions using Rake as glue.
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
- features/cross-package.feature
- features/package.feature
- features/step_definitions/compilation.rb
- features/step_definitions/cross_compilation.rb
- features/step_definitions/execution.rb
- features/step_definitions/folders.rb
- features/step_definitions/gem.rb
- features/support/env.rb
- features/support/file_templates.rb
- features/support/generators.rb
- bin/rake-compiler
- lib/rake/extensiontask.rb
- spec/lib/rake/extensiontask_spec.rb
- spec/spec_helper.rb
- tasks/bin/cross-ruby.rake
- tasks/common.rake
- tasks/cucumber.rake
- tasks/rdoc.rake
- tasks/rspec.rake
- tasks/rubygems.rake
- Rakefile
- README.rdoc
- History.txt
- LICENSE.txt
- cucumber.yml
has_rdoc: true
homepage: http://github.com/luislavena/rake-compiler
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

rubyforge_project: TODO
rubygems_version: 1.3.0
signing_key: 
specification_version: 2
summary: Rake-based Ruby C Extension task generator.
test_files: []

