require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'rbconfig'

require 'pathname'

require_relative 'compiler_config'

module Rake
  class BaseExtensionTask < TaskLib
    attr_accessor :name, :gem_spec, :tmp_dir, :ext_dir, :lib_dir, :config_options, :source_pattern, :extra_options,
                  :extra_sources
    attr_writer :platform

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
      @lib_dir += "/#{File.dirname(@name.to_s)}" if @name and File.dirname(@name.to_s) != '.'
      @config_options = []
      @extra_options = ARGV.select { |i| i =~ /\A--?/ }
      @extra_sources = FileList[]
    end

    def define
      raise 'Extension name must be provided.' if @name.nil?

      @name = @name.to_s

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
      FileList["#{@ext_dir}/#{@source_pattern}"] + @extra_sources
    end

    def warn_once(message)
      @@already_warned ||= false
      return if @@already_warned

      @@already_warned = true
      warn message
    end

    def windows?
      Rake.application.windows?
    end
  end
end
