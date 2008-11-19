def template_rakefile
<<-EOF
# add rake-compiler lib dir to the LOAD_PATH
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib'))

require 'rubygems'
require 'rake'

# load rakefile extensions (tasks)
Dir['tasks/*.rake'].each { |f| import f }
EOF
end

def template_rake_extension(extension_name)
<<-EOF
require 'rake/extensiontask'
Rake::ExtensionTask.new("#{extension_name}")
EOF
end

def template_extconf(extension_name)
<<-EOF
require 'mkmf'
create_makefile("#{extension_name}")
EOF
end

def template_source_c(extension_name)
<<-EOF
#include "source.h"
void Init_#{extension_name}()
{
  printf("source.c of extension #{extension_name}\\n");
}
EOF
end

def template_source_h
<<-EOF
#include "ruby.h"
EOF
end
