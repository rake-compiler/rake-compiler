begin
  require 'cucumber/rake/task'
rescue LoadError
  warn "Cucumber gem is required, please install it. (gem install cucumber)"
end

if defined?(Cucumber)
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = "--format pretty --no-source"
  end
end

