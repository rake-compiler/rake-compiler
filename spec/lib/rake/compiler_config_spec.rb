require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rake/extensiontask'
require 'rbconfig'
require 'tempfile'

describe Rake::CompilerConfig do
  def config_file(contents)
    Tempfile.new.tap do |tf|
      tf.write(contents)
      tf.close
    end
  end

  it "returns the matching config for exact platform match" do
    cc = Rake::CompilerConfig.new(config_file(<<~CONFIG))
      ---
      rbconfig-x86_64-linux-3.0.0: "/path/to/aaa/rbconfig.rb"
      rbconfig-x86_64-darwin-3.1.0: "/path/to/bbb/rbconfig.rb"
      rbconfig-x86_64-linux-3.1.0: "/path/to/ccc/rbconfig.rb"
    CONFIG

    expect(cc.find("3.0.0", "x86_64-linux")).to eq("/path/to/aaa/rbconfig.rb")
    expect(cc.find("3.1.0", "x86_64-darwin")).to eq("/path/to/bbb/rbconfig.rb")
    expect(cc.find("3.1.0", "x86_64-linux")).to eq("/path/to/ccc/rbconfig.rb")

    expect(cc.find("2.7.0", "x86_64-linux")).to be_nil
    expect(cc.find("3.1.0", "arm64-linux")).to be_nil
  end
end
