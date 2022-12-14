module Rake
  class CompilerConfig
    def initialize(config_path)
      require "yaml"
      @config = YAML.load_file(config_path)
    end

    def find(ruby_version, gem_platform)
      @config["rbconfig-#{gem_platform}-#{ruby_version}"]
    end
  end
end
