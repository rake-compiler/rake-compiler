begin
  gem 'rcov', '~> 0.8.1'
  require 'rcov'
  require 'spec/rake/spectask'
rescue
  raise "RCov gem no found. Required as development dependency. (gem install rcov)."
end

CLOBBER.include('coverage')

namespace :spec do
  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts   = ["--options", "spec/spec.opts"]
    t.spec_files  = FileList["spec/**/*_spec.rb"]
    t.rcov        = true
    t.rcov_opts   = ["--exclude", "spec/*,features/*,gems/*"]
  end
end
