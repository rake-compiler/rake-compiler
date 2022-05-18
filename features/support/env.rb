require 'cucumber'
require 'rspec'
require 'fileutils'
require 'rbconfig'

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), '../..'))

# get rid of Bundler environment polution
define('Bundler') and
  ENV.delete('RUBYOPT')
