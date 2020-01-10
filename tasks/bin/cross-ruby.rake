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

begin
  require 'psych'
rescue LoadError
end

require 'yaml'
require "rbconfig"

# load compiler helpers
# add lib directory to the search path
libdir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

if RUBY_PLATFORM =~ /mingw|mswin/ then
  puts "This command is meant to be executed under Linux or OSX, not Windows (is for cross-compilation)"
  exit(1)
end

require 'rake/extensioncompiler'

MAKE = ENV['MAKE'] || %w[gmake make].find { |c| system("#{c} -v > /dev/null 2>&1") }
USER_HOME = File.expand_path("~/.rake-compiler")
RUBY_CC_VERSION = "ruby-" + ENV.fetch("VERSION", "1.8.7-p371")
RUBY_SOURCE = ENV['SOURCE']
RUBY_BUILD = RbConfig::CONFIG["host"]

# grab the major "1.8" or "1.9" part of the version number
MAJOR = RUBY_CC_VERSION.match(/.*-(\d.\d).\d/)[1]

# Unset any possible variable that might affect compilation
["CC", "CXX", "CPPFLAGS", "LDFLAGS", "RUBYOPT"].each do |var|
  ENV.delete(var)
end

# define a location where sources will be stored
source_dir = "#{USER_HOME}/sources/#{RUBY_CC_VERSION}"
directory source_dir
# clean intermediate files and folders
CLEAN.include(source_dir)

# remove the final products and sources
CLOBBER.include("#{USER_HOME}/sources")
CLOBBER.include("#{USER_HOME}/builds")
CLOBBER.include("#{USER_HOME}/config.yml")

# Extract the sources
source_file = RUBY_SOURCE ? RUBY_SOURCE.split('/').last : "#{RUBY_CC_VERSION}.tar.bz2"
file source_dir => ["#{USER_HOME}/sources/#{source_file}"] do |t|
  chdir File.dirname(t.name) do
    t.prerequisites.each { |f| sh "tar xf #{File.basename(f)}" }
  end
end

# ruby source file should be stored there
file "#{USER_HOME}/sources/#{RUBY_CC_VERSION}.tar.bz2" => ["#{USER_HOME}/sources"] do |t|
  # download the source file using wget or curl
  chdir File.dirname(t.name) do
    if RUBY_SOURCE
      url = RUBY_SOURCE
    else
      url = "http://cache.ruby-lang.org/pub/ruby/#{MAJOR}/#{File.basename(t.name)}"
    end
    sh "wget #{url} || curl -O #{url}"
  end
end

# Create tasks for each host out of the ":" separated hosts list in the HOST variable.
# These tasks are processed in parallel as dependencies to the "install" task.
MINGW_HOSTS = ENV['HOST'] || Rake::ExtensionCompiler.mingw_host
MINGW_HOSTS.split(":").each do |mingw_host|

  # Use Rake::ExtensionCompiler helpers to find the proper host
  mingw_target = mingw_host.gsub('msvc', '')

  # define a location where built files for each host will be stored
  build_dir = "#{USER_HOME}/builds/#{mingw_host}/#{RUBY_CC_VERSION}"
  directory build_dir
  install_dir = "#{USER_HOME}/ruby/#{mingw_host}/#{RUBY_CC_VERSION}"

  # clean intermediate files and folders
  CLEAN.include(build_dir)
  CLOBBER.include(install_dir)

  task :mingw32 do
    unless mingw_host then
      warn "You need to install mingw32 cross compile functionality to be able to continue."
      warn "Please refer to your distribution/package manager documentation about installation."
      fail
    end
  end

  # generate the makefile in a clean build location
  file "#{build_dir}/Makefile" => [build_dir, source_dir] do |t|

    options = [
      "--host=#{mingw_host}",
      "--target=#{mingw_target}",
      "--build=#{RUBY_BUILD}",
      '--enable-shared',
      '--disable-install-doc',
      '--with-ext=',
      'LDFLAGS=-pipe -s',
    ]

    # Force Winsock2 for Ruby 1.8, 1.9 defaults to it
    options << "--with-winsock2" if MAJOR == "1.8"
    options << "--prefix=#{install_dir}"
    sh File.expand_path("#{USER_HOME}/sources/#{RUBY_CC_VERSION}/configure"), *options, chdir: File.dirname(t.name)
  end

  # make
  file "#{build_dir}/ruby.exe" => ["#{build_dir}/Makefile"] do |t|
    sh MAKE, chdir: File.dirname(t.prerequisites.first)
  end

  # make install
  file "#{USER_HOME}/ruby/#{mingw_host}/#{RUBY_CC_VERSION}/bin/ruby.exe" => ["#{build_dir}/ruby.exe"] do |t|
    sh "#{MAKE} install", chdir: File.dirname(t.prerequisites.first)
  end
  multitask :install => ["#{USER_HOME}/ruby/#{mingw_host}/#{RUBY_CC_VERSION}/bin/ruby.exe"]
end


desc "Update rake-compiler list of installed Ruby versions"
task 'update-config' do
  config_file = "#{USER_HOME}/config.yml"
  File.open(config_file, File::RDWR|File::CREAT) do |config_fd|
    config_fd.flock(File::LOCK_EX)
    config = YAML.load(config_fd.read)
    if config
      puts "Updating #{config_file}"
    else
      puts "Generating #{config_file}"
      config = {}
    end

    files = Dir.glob("#{USER_HOME}/ruby/*/*/**/rbconfig.rb").sort

    files.each do |rbconfig|
      version, platform = rbconfig.match(/.*-(\d.\d.\d).*\/([-\w]+)\/rbconfig/)[1,2]
      platforms = [platform]

      # fake alternate (binary compatible) i386-mswin32-60 platform
      platform == "i386-mingw32" and
        platforms.push "i386-mswin32-60"

      platforms.each do |plat|
        config["rbconfig-#{plat}-#{version}"] = rbconfig

        # also store RubyGems-compatible version
        gem_platform = Gem::Platform.new(plat)
        config["rbconfig-#{gem_platform}-#{version}"] = rbconfig
      end

      puts "Found Ruby version #{version} for platform #{platform} (#{rbconfig})"
    end

    when_writing("Saving changes into #{config_file}") {
      config_fd.rewind
      config_fd.puts config.to_yaml
    }
  end
end

task :default do
  # Force the display of the available tasks when no option is given
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end

desc "Build #{RUBY_CC_VERSION} suitable for cross-platform development."
task 'cross-ruby' => [:mingw32, :install, 'update-config']
