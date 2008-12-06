begin
  gem 'cucumber', '~> 0.1.8'
  require 'cucumber/rake/task'
rescue Exception
  nil
end

if defined?(Cucumber)
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = "--format pretty --no-source"
  end

  # make packing depend on success of running specs
  task :package => [:features]
else
  warn "Cucumber gem is required, please install it. (gem install cucumber)"
end
