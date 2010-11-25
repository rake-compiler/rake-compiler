require 'rake/clean'

# common pattern cleanup
CLEAN.include('tmp/project.*')

# set default task
task :default => [:spec, :features]

# make packing depend on success of running specs and features
task :package => [:spec, :features]
