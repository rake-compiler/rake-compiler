#!/usr/bin/env ruby

# Define a series of tasks to aid in the compilation of C extensions for
# gem developer/creators.

require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'rbconfig'

module Rake
  autoload :GemPackageTask, 'rake/gempackagetask'

  class ExtensionTask < TaskLib
    attr_accessor :name
    attr_accessor :gem_spec
    attr_accessor :config_script
    attr_accessor :tmp_dir
    attr_accessor :ext_dir
    attr_accessor :lib_dir
    attr_accessor :platform
    attr_accessor :additional_options
    attr_accessor :source_pattern

    def initialize(name = nil, gem_spec = nil)
      init(name, gem_spec)
      yield self if block_given?
      define
    end

    def init(name = nil, gem_spec = nil)
      @name = name
      @gem_spec = gem_spec
      @config_script = 'extconf.rb'
      @tmp_dir = 'tmp'
      @ext_dir = 'ext'
      @lib_dir = 'lib'
      @source_pattern = "*.c"
      @additional_options = []
    end

    def platform
      @platform ||= RUBY_PLATFORM
    end

    def define
      fail "Extension name must be provided." if @name.nil?

      define_compile_tasks
      define_native_tasks if @gem_spec
    end

    private
    def define_compile_tasks(for_platform = nil)
      # platform usage
      platf = for_platform || platform

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{platf}/#{@name}"

      # cleanup and clobbering
      CLEAN.include(tmp_path)
      CLOBBER.include("#{@lib_dir}/#{binary}")
      CLOBBER.include("#{@tmp_dir}")

      # directories we need
      directory tmp_path
      directory lib_dir

      # copy binary from temporary location to final lib
      # tmp/extension_name/extension_name.{so,bundle} => lib/
      task "copy:#{@name}:#{platf}" => [lib_dir, "#{tmp_path}/#{binary}"] do
        cp "#{tmp_path}/#{binary}", "#{@lib_dir}/#{binary}"
      end

      # ensure file is always copied
      file "#{@lib_dir}/#{binary}" => ["copy:#{name}:#{platf}"]

      # binary in temporary folder depends on makefile and source files
      # tmp/extension_name/extension_name.{so,bundle}
      file "#{tmp_path}/#{binary}" => ["#{tmp_path}/Makefile"] + source_files do
        chdir tmp_path do
          sh make
        end
      end

      # makefile depends of tmp_dir and config_script
      # tmp/extension_name/Makefile
      file "#{tmp_path}/Makefile" => [tmp_path, extconf] do
        parent = Dir.pwd
        chdir tmp_path do
          # FIXME: Rake is broken for multiple arguments system() calls.
          # Add current directory to the search path of Ruby
          # Also, include additional parameters supplied.
          ruby ['-I.', File.join(parent, extconf), *@additional_options].join(' ')
        end
      end

      # compile tasks
      unless Rake::Task.task_defined?('compile') then
        desc "Compile all the extensions"
        task "compile"
      end

      # Allow segmented compilation by platfrom (open door for 'cross compile')
      task "compile:#{@name}:#{platf}" => ["copy:#{@name}:#{platf}"]
      task "compile:#{platf}" => ["compile:#{@name}:#{platf}"]

      # Only add this extension to the compile chain if current
      # platform matches the indicated one.
      if platf == RUBY_PLATFORM then
        task "compile:#{@name}" => ["compile:#{@name}:#{platf}"]
        task "compile" => ["compile:#{platf}"]
      end
    end

    def define_native_tasks
      # only gems with 'ruby' platforms are allowed to define native tasks
      return unless @gem_spec.platform == 'ruby'

      # create 'native:gem_name' and chain it to 'native' task
      native_task_for(@gem_spec)

      # hook the binary to the prerequisites for this task
      task native_task_gem => ["#{@lib_dir}/#{binary}"]
    end

    def extconf
      "#{@ext_dir}/#{@name}/#{@config_script}"
    end

    def make
      RUBY_PLATFORM =~ /mswin/ ? 'nmake' : 'make'
    end

    def binary
      "#{@name}.#{RbConfig::CONFIG['DLEXT']}"
    end

    def source_files
     @source_files ||= FileList["#{@ext_dir}/#{@name}/#{@source_pattern}"]
    end

    def native_task_gem
      "native:#{@gem_spec.name}"
    end

    def native_task_for(gem_spec)
      return if Rake::Task.task_defined?(native_task_gem)

      spec = gem_spec.dup

      task native_task_gem do |t|
        # adjust to current platform
        spec.platform = (@platform || Gem::Platform::CURRENT)

        # clear the extensions defined in the specs
        spec.extensions.clear

        # add the binary dependencies of this task
        spec.files += t.prerequisites

        # Generate a package for this gem
        gem_package = Rake::GemPackageTask.new(spec) do |pkg|
          pkg.need_zip = false
          pkg.need_tar = false
        end
      end

      # add this native task to the list
      task "native" => [native_task_gem]
    end
  end
end
