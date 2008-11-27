#--
# Cross-compile ruby, using Rake
#
# This source code is released under the MIT License.
# See LICENSE file for details
#++

#
# This code is inspired and based on notes from the following sites:
#
# http://tenderlovemaking.com/2008/11/21/cross-compiling-ruby-gems-for-win32/
# http://github.com/jbarnette/johnson/tree/master/cross-compile.txt
# http://eigenclass.org/hiki/cross+compiling+rcovrt
#
# This recipe only cleanup the dependency chain and automate it.
# Also opens the door to usage different ruby versions 
# for cross-compilation.
#

require 'rake'
require 'rake/clean'
require 'yaml'

HOME = File.expand_path("~/.rake-compiler")
RUBY = "ruby-#{ENV['VERSION'] || '1.8.6-p287'}"

# grab the major "1.8" or "1.9" part of the version number
MAJOR = RUBY.match(/.*-(\d.\d).\d/)[1]

# define a location where sources will be stored
directory "#{HOME}/sources/#{RUBY}"
directory "#{HOME}/builds/#{RUBY}"

# clean intermediate files and folders
CLEAN.include("#{HOME}/sources/#{RUBY}")
CLEAN.include("#{HOME}/builds/#{RUBY}")

# remove the final products and sources
CLOBBER.include("#{HOME}/sources")
CLOBBER.include("#{HOME}/builds")
CLOBBER.include("#{HOME}/ruby/#{RUBY}")
CLOBBER.include("#{HOME}/config.yml")

# ruby source file should be stored there
file "#{HOME}/sources/#{RUBY}.tar.gz" => ["#{HOME}/sources"] do |t|
  # download the source file using wget or curl
  chdir File.dirname(t.name) do
    url = "ftp://ftp.ruby-lang.org/pub/ruby/#{MAJOR}/#{File.basename(t.name)}"
    sh "wget #{url} || curl -O #{url}"
  end
end

# Extract the sources
file "#{HOME}/sources/#{RUBY}" => ["#{HOME}/sources/#{RUBY}.tar.gz"] do |t|
  chdir File.dirname(t.name) do
    t.prerequisites.each { |f| sh "tar xfz #{File.basename(f)}" }
  end
end

# backup makefile.in
file "#{HOME}/sources/#{RUBY}/Makefile.in.bak" => ["#{HOME}/sources/#{RUBY}"] do |t|
  cp "#{HOME}/sources/#{RUBY}/Makefile.in", t.name
end

# correct the makefiles
file "#{HOME}/sources/#{RUBY}/Makefile.in" => ["#{HOME}/sources/#{RUBY}/Makefile.in.bak"] do |t|
  content = File.open(t.name, 'rb') { |f| f.read }

  out = ""

  content.each_line do |line|
    if line =~ /^\s*ALT_SEPARATOR =/
      out << "\t\t    ALT_SEPARATOR = \"\\\\\\\\\"; \\\n"
    else
      out << line
    end
  end

  File.open(t.name, 'wb') { |f| f.write(out) }
end

task :mingw32 do
  unless File.exist?('/usr/bin/i586-mingw32msvc-gcc') then
    warn "You need to install mingw32 cross compile functionality"
    warn "to be able to continue."
    warn "Please refer to your distro documentation about installation."
    fail
  end
end

task :environment do
  ENV['ac_cv_func_getpgrp_void'] =  'no'
  ENV['ac_cv_func_setpgrp_void'] = 'yes'
  ENV['rb_cv_negative_time_t'] = 'no'
  ENV['ac_cv_func_memcmp_working'] = 'yes'
  ENV['rb_cv_binary_elf' ] = 'no'
end

# generate the makefile in a clean build location
file "#{HOME}/builds/#{RUBY}/Makefile" => ["#{HOME}/builds/#{RUBY}",
                                  "#{HOME}/sources/#{RUBY}/Makefile.in"] do |t|

  # set the configure options
  options = [
    '--host=i586-mingw32msvc',
    '--target=i386-mingw32',
    '--build=i686-linux',
    '--enable-shared'
  ]

  chdir File.dirname(t.name) do
    prefix = File.expand_path("../../ruby/#{RUBY}")
    options << "--prefix=#{prefix}"
    sh File.expand_path("../../sources/#{RUBY}/configure"), *options
  end
end

# make
file "#{HOME}/builds/#{RUBY}/ruby.exe" => ["#{HOME}/builds/#{RUBY}/Makefile"] do |t|
  chdir File.dirname(t.prerequisites.first) do
    sh "make"
  end
end

# make install
file "#{HOME}/ruby/#{RUBY}/bin/ruby.exe" => ["#{HOME}/builds/#{RUBY}/ruby.exe"] do |t|
  chdir File.dirname(t.prerequisites.first) do
    sh "make install"
  end
end

# rbconfig.rb location
file "#{HOME}/ruby/#{RUBY}/lib/ruby/#{MAJOR}/i386-mingw32/rbconfig.rb" => ["#{HOME}/ruby/#{RUBY}/bin/ruby.exe"]

file "#{HOME}/config.yml" => ["#{HOME}/ruby/#{RUBY}/lib/ruby/#{MAJOR}/i386-mingw32/rbconfig.rb"] do |t|
  if File.exist?(t.name) then
    puts "Updating #{t.name}"
    config = YAML.load_file(t.name)
  else
    puts "Generating #{t.name}"
    config = {}
  end

  config["rbconfig-#{MAJOR}"] = File.expand_path(t.prerequisites.first)

  File.open(t.name, 'w') do |f|
    f.puts config.to_yaml
  end
end

task :default do
end

desc "Build #{RUBY} suitable for cross-platform development."
task 'cross-ruby' => [:mingw32, :environment, "#{HOME}/config.yml"]
