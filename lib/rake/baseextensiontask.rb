require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'rbconfig'
require 'yaml'
require 'pathname'

module Rake
  autoload :GemPackageTask, 'rake/gempackagetask'

  class BaseExtensionTask < TaskLib

    attr_accessor :name
    attr_accessor :gem_spec
    attr_accessor :tmp_dir
    attr_accessor :ext_dir
    attr_accessor :lib_dir
    attr_accessor :platform
    attr_accessor :config_options
    attr_accessor :source_pattern

    def platform
      @platform ||= RUBY_PLATFORM
    end

    def initialize(name = nil, gem_spec = nil)
      init(name, gem_spec)
      yield self if block_given?
      define
    end

    def init(name = nil, gem_spec = nil)
      @name = name
      @gem_spec = gem_spec
      @tmp_dir = 'tmp'
      @ext_dir = "ext/#{@name}"
      @lib_dir = 'lib'
      @config_options = []
    end

    def define
      fail "Extension name must be provided." if @name.nil?

      define_compile_tasks
    end

    private

    def define_compile_tasks
      raise NotImplementedError
    end

    def binary(platform = nil)
      ext = case platform
        when /darwin/
          'bundle'
        when /mingw|mswin|linux/
          'so'
        when /java/
          'jar'
        else
          RbConfig::CONFIG['DLEXT']
      end
      "#{@name}.#{ext}"
    end

    def source_files
      @source_files ||= FileList["#{@ext_dir}/#{@source_pattern}"]
    end
  end
end
