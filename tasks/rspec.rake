begin
  gem 'rspec', '~> 1.1.9'
  require 'spec/rake/spectask'
rescue
  raise "RSpec gem no found. Required as development dependency. (gem install rspec)."
end

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts   = ["--options", "spec/spec.opts"]
  t.spec_files  = FileList["spec/**/*_spec.rb"]
end
