#--
# Copyright (c) 2008 Luis Lavena
#
# This source code is released under the MIT License.
# See LICENSE file for details
#++

#
# NOTE: Keep this file clean.
# Add your customizations inside tasks directory.
# Thank You.
#

begin
  require "isolate/now"
rescue LoadError => e
  abort "This project requires Isolate to work. Please `gem install isolate` and try again."
end

# load rakefile extensions (tasks)
Dir['tasks/*.rake'].sort.each { |f| load f }
