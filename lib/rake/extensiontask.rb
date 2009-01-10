#!/usr/bin/env ruby

# Define a series of tasks to aid in the compilation of C extensions for
# gem developer/creators.

require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'rbconfig'

module Rake
  autoload :GemPackageTask, 'rake/gempackagetask'
  autoload :YAML, 'yaml'

  class ExtensionTask < TaskLib
    attr_accessor :name
    attr_accessor :gem_spec
    attr_accessor :config_script
    attr_accessor :tmp_dir
    attr_accessor :ext_dir
    attr_accessor :lib_dir
    attr_accessor :platform
    attr_accessor :config_options
    attr_accessor :source_pattern
    attr_accessor :cross_compile
    attr_accessor :cross_platform
    attr_accessor :cross_config_options

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
      @config_options = []
      @cross_compile = false
      @cross_config_options = []
    end

    def platform
      @platform ||= RUBY_PLATFORM
    end

    def cross_platform
      @cross_platform ||= 'i386-mingw32'
    end

    def define
      fail "Extension name must be provided." if @name.nil?

      define_compile_tasks

      # only gems with 'ruby' platforms are allowed to define native tasks
      define_native_tasks if @gem_spec && @gem_spec.platform == 'ruby'

      # only define cross platform functionality when enabled
      # FIXME: there is no value for having this on Windows or JRuby
      define_cross_platform_tasks if @cross_compile
    end

    private
    def define_compile_tasks(for_platform = nil)
      # platform usage
      platf = for_platform || platform

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{platf}/#{@name}"

      # cleanup and clobbering
      CLEAN.include(tmp_path)
      CLOBBER.include("#{@lib_dir}/#{binary(platf)}")
      CLOBBER.include("#{@tmp_dir}")

      # directories we need
      directory tmp_path
      directory lib_dir

      # copy binary from temporary location to final lib
      # tmp/extension_name/extension_name.{so,bundle} => lib/
      task "copy:#{@name}:#{platf}" => [lib_dir, "#{tmp_path}/#{binary(platf)}"] do
        cp "#{tmp_path}/#{binary(platf)}", "#{@lib_dir}/#{binary(platf)}"
      end

      # binary in temporary folder depends on makefile and source files
      # tmp/extension_name/extension_name.{so,bundle}
      file "#{tmp_path}/#{binary(platf)}" => ["#{tmp_path}/Makefile"] + source_files do
        chdir tmp_path do
          sh make
        end
      end

      # makefile depends of tmp_dir and config_script
      # tmp/extension_name/Makefile
      file "#{tmp_path}/Makefile" => [tmp_path, extconf] do |t|
        options = @config_options.dup

        # rbconfig.rb will be present if we are cross compiling
        if t.prerequisites.include?("#{tmp_path}/rbconfig.rb") then
          options.push(*@cross_config_options)
        end

        parent = Dir.pwd
        chdir tmp_path do
          # FIXME: Rake is broken for multiple arguments system() calls.
          # Add current directory to the search path of Ruby
          # Also, include additional parameters supplied.
          ruby ['-I.', File.join(parent, extconf), *options].join(' ')
        end
      end

      # compile tasks
      unless Rake::Task.task_defined?('compile') then
        desc "Compile all the extensions"
        task "compile"
      end

      # compile:name
      unless Rake::Task.task_defined?("compile:#{@name}") then
        desc "Compile #{@name}"
        task "compile:#{@name}"
      end

      # Allow segmented compilation by platform (open door for 'cross compile')
      task "compile:#{@name}:#{platf}" => ["copy:#{@name}:#{platf}"]
      task "compile:#{platf}" => ["compile:#{@name}:#{platf}"]

      # Only add this extension to the compile chain if current
      # platform matches the indicated one.
      if platf == RUBY_PLATFORM then
        # ensure file is always copied
        file "#{@lib_dir}/#{binary(platf)}" => ["copy:#{name}:#{platf}"]

        task "compile:#{@name}" => ["compile:#{@name}:#{platf}"]
        task "compile" => ["compile:#{platf}"]
      end
    end

    def define_native_tasks(for_platform = nil)
      platf = for_platform || platform

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{platf}/#{@name}"

      # create 'native:gem_name' and chain it to 'native' task
      unless Rake::Task.task_defined?("native:#{@gem_spec.name}:#{platf}")
        task "native:#{@gem_spec.name}:#{platf}" do |t|
          # FIXME: truly duplicate the Gem::Specification
          # workaround the lack of #dup for Gem::Specification
          spec = Gem::Specification.from_yaml(gem_spec.to_yaml)

          # adjust to specified platform
          spec.platform = platf

          # clear the extensions defined in the specs
          spec.extensions.clear

          # add the binaries that this task depends on
          # ensure the files get properly copied to lib_dir
          ext_files = t.prerequisites.map { |ext| "#{@lib_dir}/#{File.basename(ext)}" }
          ext_files.each do |ext|
            unless Rake::Task.task_defined?("#{@lib_dir}/#{File.basename(ext)}") then
              # strip out path and .so/.bundle
              file "#{@lib_dir}/#{File.basename(ext)}" => ["copy:#{File.basename(ext).ext('')}:#{platf}"]
            end
          end

          # include the files in the gem specification
          spec.files += ext_files

          # Generate a package for this gem
          gem_package = Rake::GemPackageTask.new(spec) do |pkg|
            pkg.need_zip = false
            pkg.need_tar = false
          end

          # ensure the binaries are copied
          task "#{gem_package.package_dir}/#{gem_package.gem_file}" => ["copy:#{@name}:#{platf}"]
        end
      end

      # add binaries to the dependency chain
      task "native:#{@gem_spec.name}:#{platf}" => ["#{tmp_path}/#{binary(platf)}"]

      # Allow segmented packaging by platfrom (open door for 'cross compile')
      task "native:#{platf}" => ["native:#{@gem_spec.name}:#{platf}"]

      # Only add this extension to the compile chain if current
      # platform matches the indicated one.
      if platf == RUBY_PLATFORM then
        task "native:#{@gem_spec.name}" => ["native:#{@gem_spec.name}:#{platf}"]
        task "native" => ["native:#{platf}"]
      end
    end

    def define_cross_platform_tasks
      config_path = File.expand_path("~/.rake-compiler/config.yml")
      major_ver = (ENV['RUBY_CC_VERSION'] || RUBY_VERSION).match(/(\d+.\d+)/)[1]

      # warn the user about the need of configuration to use cross compilation.
      unless File.exist?(config_path)
        warn "rake-compiler must be configured first to enable cross-compilation"
        return
      end

      config_file = YAML.load_file(config_path)

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{cross_platform}/#{@name}"

      unless rbconfig_file = config_file["rbconfig-#{major_ver}"] then
        fail "no configuration section for this version of Ruby (rbconfig-#{major_ver})"
      end

      # define compilation tasks for cross platfrom!
      define_compile_tasks(cross_platform)

      # chain rbconfig.rb to Makefile generation
      file "#{tmp_path}/Makefile" => ["#{tmp_path}/rbconfig.rb"]

      # copy the file from the cross-ruby location
      file "#{tmp_path}/rbconfig.rb" => [rbconfig_file] do |t|
        cp t.prerequisites.first, t.name
      end

      # now define native tasks for cross compiled files
      define_native_tasks(cross_platform) if @gem_spec && @gem_spec.platform == 'ruby'

      # create cross task
      task 'cross' do
        # clear compile dependencies
        Rake::Task['compile'].prerequisites.clear

        # chain the cross platform ones
        task 'compile' => ["compile:#{cross_platform}"]

        # clear lib/binary dependencies and trigger cross platform ones
        # check if lib/binary is defined (damn bundle versus so versus dll)
        if Rake::Task.task_defined?("#{@lib_dir}/#{binary(cross_platform)}") then
          Rake::Task["#{@lib_dir}/#{binary(cross_platform)}"].prerequisites.clear
        end
        file "#{@lib_dir}/#{binary(cross_platform)}" => ["copy:#{@name}:#{cross_platform}"]

        # if everything for native task is in place
        if @gem_spec && @gem_spec.platform == 'ruby' then
          Rake::Task['native'].prerequisites.clear
          task 'native' => ["native:#{cross_platform}"]
        end
      end
    end

    def extconf
      "#{@ext_dir}/#{@name}/#{@config_script}"
    end

    def make
      RUBY_PLATFORM =~ /mswin/ ? 'nmake' : 'make'
    end

    def binary(platform = nil)
      ext = case platform
        when /darwin/
          'bundle'
        when /mingw|mswin|linux/
          'so'
        else
          RbConfig::CONFIG['DLEXT']
      end
      "#{@name}.#{ext}"
    end

    def source_files
     @source_files ||= FileList["#{@ext_dir}/#{@name}/#{@source_pattern}"]
    end
  end
end
