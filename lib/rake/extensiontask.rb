#!/usr/bin/env ruby

# Define a series of tasks to aid in the compilation of C extensions for
# gem developer/creators.

require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'rbconfig'

module Rake
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
    def define_compile_tasks
      # directories we need
      directory tmp_path
      directory @lib_dir

      # platform specific temp folder should be on the cleaning
      CLEAN.include(tmp_path)

      # makefile depends of tmp_dir and config_script
      # tmp/extension_name/Makefile
      file makefile => [tmp_path, extconf] do
        parent = Dir.pwd
        Dir.chdir tmp_path do
          # FIXME: Rake is broken for multiple arguments system() calls.
          # Add current directory to the search path of Ruby
          # Also, include additional parameters supplied.
          ruby ['-I.', File.join(parent, extconf), *@additional_options].join(' ')
        end
      end

      # binary in temporary folder depends on makefile and source files
      # tmp/extension_name/extension_name.{so,bundle}
      file tmp_binary => [makefile] + source_files do
        Dir.chdir tmp_path do
          sh make
        end
      end

      # copy binary from temporary location to final lib
      # tmp/extension_name/extension_name.{so,bundle} => lib/
      file lib_binary => [lib_path, tmp_binary] do
        cp tmp_binary, lib_binary
      end

      # clobbering should remove the binaries from lib_path
      CLOBBER.include(lib_binary)

      # we should also clobber the tmp folder
      CLOBBER.include(@tmp_dir)

      desc "Compile just the #{@name} extension"
      task "compile:#{@name}" => [lib_binary]

      desc "Compile the extension(s)" unless Rake::Task.task_defined?('compile')
      task "compile" => ["compile:#{@name}"]
    end

    def define_native_tasks
      # only gems with 'ruby' platforms are allowed to define native tasks
      return unless @gem_spec.platform == 'ruby'

      require 'rake/gempackagetask' unless defined?(Rake::GemPackageTask)

      # create 'native:gem_name' and chain it to 'native' task
      native_task_for(@gem_spec)

      # hook the binary to the prerequisites for this task
      task native_task_gem => [lib_binary]
    end

    def makefile
      "#{tmp_path}/Makefile"
    end

    def extconf
      "#{ext_path}/#{@config_script}"
    end

    def tmp_path
      File.join(@tmp_dir, platform, @name)
    end

    def ext_path
      File.join(@ext_dir, @name)
    end

    def lib_path
      @lib_dir
    end

    def make
      RUBY_PLATFORM =~ /mswin/ ? 'nmake' : 'make'
    end

    def binary
      "#{@name}.#{RbConfig::CONFIG['DLEXT']}"
    end

    def source_files
     @source_files ||= FileList["#{ext_path}/#{@source_pattern}"]
    end

    def tmp_binary
      "#{tmp_path}/#{binary}"
    end

    def lib_binary
      "#{lib_path}/#{binary}"
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
