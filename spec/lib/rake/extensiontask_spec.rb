require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rake/extensiontask'
require 'rbconfig'

describe Rake::ExtensionTask do
  describe '#new' do
    describe '(basic)' do
      it 'should raise an error if no name is provided' do
        lambda {
          Rake::ExtensionTask.new
        }.should raise_error(RuntimeError, /Extension name must be provided/)
      end

      it 'should allow string as extension name assignation' do
        ext = Rake::ExtensionTask.new('extension_one')
        ext.name.should == 'extension_one'
      end

      it 'should allow string as extension name using block assignation' do
        ext = Rake::ExtensionTask.new do |ext|
          ext.name = 'extension_two'
        end
        ext.name.should == 'extension_two'
      end

      it 'should return itself for the block' do
        from_block = nil
        from_lasgn = Rake::ExtensionTask.new('extension_three') do |ext|
          from_block = ext
        end
        from_block.should == from_lasgn
      end

      it 'should accept a gem specification as parameter' do
        spec = mock_gem_spec
        ext = Rake::ExtensionTask.new('extension_three', spec)
        ext.gem_spec.should == spec
      end

      it 'should allow gem specification be defined using block assignation' do
        spec = mock_gem_spec
        ext = Rake::ExtensionTask.new('extension_four') do |ext|
          ext.gem_spec = spec
        end
        ext.gem_spec.should == spec
      end

      it 'should allow forcing of platform' do
        ext = Rake::ExtensionTask.new('weird_extension') do |ext|
          ext.platform = 'universal-foo-bar-10.5'
        end
        ext.platform.should == 'universal-foo-bar-10.5'
      end
    end
  end

  describe '(defaults)' do
    before :each do
      @ext = Rake::ExtensionTask.new('extension_one')
    end

    it 'should look for extconf script' do
      @ext.config_script.should == 'extconf.rb'
    end

    it 'should dump intermediate files to tmp/' do
      @ext.tmp_dir.should == 'tmp'
    end

    it 'should look for extension inside ext/' do
      @ext.ext_dir.should == 'ext'
    end

    it 'should copy build extension into lib/' do
      @ext.lib_dir.should == 'lib'
    end

    it 'should look for C files pattern (.c)' do
      @ext.source_pattern.should == "*.c"
    end

    it 'should have no configuration options preset to delegate' do
      @ext.config_options.should be_empty
    end

    it 'should default to current platform' do
      @ext.platform.should == RUBY_PLATFORM
    end

    it 'should default to no cross compilation' do
      @ext.cross_compile.should be_false
    end

    it 'should have no configuration options for cross compilation' do
      @ext.cross_config_options.should be_empty
    end

    it "should have cross platform defined to 'i386-mingw32'" do
      @ext.cross_platform.should == 'i386-mingw32'
    end
  end

  describe '(tasks)' do
    before :each do
      Rake.application.clear
      CLEAN.clear
      CLOBBER.clear
    end

    describe '(one extension)' do
      before :each do
        Rake::FileList.stub!(:[]).and_return(["ext/extension_one/source.c"])
        @ext = Rake::ExtensionTask.new('extension_one')
        @ext_bin = ext_bin('extension_one')
        @platform = RUBY_PLATFORM
      end

      describe 'compile' do
        it 'should define as task' do
          Rake::Task.task_defined?('compile').should be_true
        end

        it "should depend on 'compile:{platform}'" do
          Rake::Task['compile'].prerequisites.should include("compile:#{@platform}")
        end
      end

      describe 'compile:extension_one' do
        it 'should define as task' do
          Rake::Task.task_defined?('compile:extension_one').should be_true
        end

        it "should depend on 'compile:extension_one:{platform}'" do
          Rake::Task['compile:extension_one'].prerequisites.should include("compile:extension_one:#{@platform}")
        end
      end

      describe 'lib/extension_one.{so,bundle}' do
        it 'should define as task' do
          Rake::Task.task_defined?("lib/#{@ext_bin}").should be_true
        end

        it "should depend on 'copy:extension_one:{platform}'" do
          Rake::Task["lib/#{@ext_bin}"].prerequisites.should include("copy:extension_one:#{@platform}")
        end
      end

      describe 'tmp/{platform}/extension_one/extension_one.{so,bundle}' do
        it 'should define as task' do
          Rake::Task.task_defined?("tmp/#{@platform}/extension_one/#{@ext_bin}").should be_true
        end

        it "should depend on 'tmp/{platform}/extension_one/Makefile'" do
          Rake::Task["tmp/#{@platform}/extension_one/#{@ext_bin}"].prerequisites.should include("tmp/#{@platform}/extension_one/Makefile")
        end

        it "should depend on 'ext/extension_one/source.c'" do
          Rake::Task["tmp/#{@platform}/extension_one/#{@ext_bin}"].prerequisites.should include("ext/extension_one/source.c")
        end

        it "should not depend on 'ext/extension_one/source.h'" do
          Rake::Task["tmp/#{@platform}/extension_one/#{@ext_bin}"].prerequisites.should_not include("ext/extension_one/source.h")
        end
      end

      describe 'tmp/{platform}/extension_one/Makefile' do
        it 'should define as task' do
          Rake::Task.task_defined?("tmp/#{@platform}/extension_one/Makefile").should be_true
        end

        it "should depend on 'tmp/{platform}/extension_one'" do
          Rake::Task["tmp/#{@platform}/extension_one/Makefile"].prerequisites.should include("tmp/#{@platform}/extension_one")
        end

        it "should depend on 'ext/extension_one/extconf.rb'" do
          Rake::Task["tmp/#{@platform}/extension_one/Makefile"].prerequisites.should include("ext/extension_one/extconf.rb")
        end
      end

      describe 'clean' do
        it "should include 'tmp/{platform}/extension_one' in the pattern" do
          CLEAN.should include("tmp/#{@platform}/extension_one")
        end
      end

      describe 'clobber' do
        it "should include 'lib/extension_one.{so,bundle}'" do
          CLOBBER.should include("lib/#{@ext_bin}")
        end

        it "should include 'tmp'" do
          CLOBBER.should include('tmp')
        end
      end
    end

    describe '(native tasks)' do
      before :each do
        Rake::FileList.stub!(:[]).and_return(["ext/extension_one/source.c"])
        @spec = mock_gem_spec
        @ext_bin = ext_bin('extension_one')
        @platform = RUBY_PLATFORM
      end

      describe 'native' do
        before :each do
          @spec.stub!(:platform=).and_return('ruby')
        end

        it 'should define a task for building the supplied gem' do
          Rake::ExtensionTask.new('extension_one', @spec)
          Rake::Task.task_defined?('native:my_gem').should be_true
        end

        it 'should define as task for pure ruby gems' do
          Rake::Task.task_defined?('native').should be_false
          Rake::ExtensionTask.new('extension_one', @spec)
          Rake::Task.task_defined?('native').should be_true
        end

        it 'should not define a task for already native gems' do
          @spec.stub!(:platform).and_return('current')
          Rake::ExtensionTask.new('extension_one', @spec)
          Rake::Task.task_defined?('native').should be_false
        end

        it 'should depend on platform specific native tasks' do
          Rake::ExtensionTask.new('extension_one', @spec)
          Rake::Task["native"].prerequisites.should include("native:#{@platform}")
        end

        describe 'native:my_gem:{platform}' do
          it 'should depend on binary extension' do
            Rake::ExtensionTask.new('extension_one', @spec)
            Rake::Task["native:my_gem:#{@platform}"].prerequisites.should include("tmp/#{@platform}/extension_one/#{@ext_bin}")
          end
        end
      end
    end

    describe '(cross platform tasks)' do
      before :each do
        File.stub!(:exist?).and_return(true)
        YAML.stub!(:load_file).and_return(mock_config_yml)
        Rake::FileList.stub!(:[]).and_return(["ext/extension_one/source.c"])
        @spec = mock_gem_spec
        @config_file = File.expand_path("~/.rake-compiler/config.yml")
        @major_ver = RUBY_VERSION.match(/(\d+.\d+)/)[1]
        @config_path = mock_config_yml["rbconfig-#{@major_ver}"]
      end

      it 'should not generate an error if no rake-compiler configuration exist' do
        File.should_receive(:exist?).with(@config_file).and_return(false)
        lambda {
          Rake::ExtensionTask.new('extension_one') do |ext|
            ext.cross_compile = true
          end
        }.should_not raise_error(RuntimeError)
      end

      it 'should parse the config file using YAML' do
        YAML.should_receive(:load_file).with(@config_file).and_return(mock_config_yml)
        Rake::ExtensionTask.new('extension_one') do |ext|
          ext.cross_compile = true
        end
      end

      it 'should fail if no section of config file defines running version of ruby' do
        config = mock(Hash)
        config.should_receive(:[]).with("rbconfig-#{@major_ver}").and_return(nil)
        YAML.stub!(:load_file).and_return(config)
        lambda {
          Rake::ExtensionTask.new('extension_one') do |ext|
            ext.cross_compile = true
          end
        }.should raise_error(RuntimeError, /no configuration section for this version of Ruby/)
      end

      it 'should allow usage of RUBY_CC_VERSION to indicate a different version of ruby' do
        config = mock(Hash)
        config.should_receive(:[]).with("rbconfig-2.0").and_return('/path/to/ruby/2.0/rbconfig.rb')
        YAML.stub!(:load_file).and_return(config)
        begin
          ENV['RUBY_CC_VERSION'] = '2.0'
          Rake::ExtensionTask.new('extension_one') do |ext|
            ext.cross_compile = true
          end
        ensure
          ENV.delete('RUBY_CC_VERSION')
        end
      end

      describe "(cross for 'universal-unknown' platform)" do
        before :each do
          @ext = Rake::ExtensionTask.new('extension_one', @spec) do |ext|
            ext.cross_compile = true
            ext.cross_platform = 'universal-unknown'
          end
        end

        describe 'rbconfig' do
          it 'should chain rbconfig tasks to Makefile generation' do
            Rake::Task['tmp/universal-unknown/extension_one/Makefile'].prerequisites.should include('tmp/universal-unknown/extension_one/rbconfig.rb')
          end

          it 'should take rbconfig from rake-compiler configuration' do
            Rake::Task['tmp/universal-unknown/extension_one/rbconfig.rb'].prerequisites.should include(@config_path)
          end
        end

        describe 'compile:universal-unknown' do
          it "should be defined" do
            Rake::Task.task_defined?('compile:universal-unknown').should be_true
          end

          it "should depend on 'compile:extension_one:universal-unknown'" do
            Rake::Task['compile:universal-unknown'].prerequisites.should include('compile:extension_one:universal-unknown')
          end
        end

        describe 'native:universal-unknown' do
          it "should be defined" do
            Rake::Task.task_defined?('native:universal-unknown').should be_true
          end

          it "should depend on 'native:my_gem:universal-unknown'" do
            Rake::Task['native:universal-unknown'].prerequisites.should include('native:my_gem:universal-unknown')
          end
        end
      end
    end
  end

  private
  def ext_bin(extension_name)
    "#{extension_name}.#{RbConfig::CONFIG['DLEXT']}"
  end

  def mock_gem_spec(stubs = {})
    mock(Gem::Specification, 
      { :name => 'my_gem', :platform => 'ruby' }.merge(stubs)
    )
  end

  def mock_config_yml
    {
      'rbconfig-1.8' => '/some/path/version/1.8/to/rbconfig.rb',
      'rbconfig-1.9' => '/some/path/version/1.9/to/rbconfig.rb'
    }
  end
end
