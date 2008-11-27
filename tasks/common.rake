require 'rake/clean'

# common pattern cleanup
CLEAN.include('tmp')

# set default task
task :default => [:spec, :features]
