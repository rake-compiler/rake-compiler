begin
  gem 'cucumber', '~> 0.1.8'
  require 'cucumber/rake/task'
rescue
  raise "Cucumber gem no found. Required as development dependency. (gem install cucumber)."
end

Cucumber::Rake::Task.new do |t|
end
