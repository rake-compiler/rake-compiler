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

    it 'should default to current platform' do
      @ext.platform.should == RUBY_PLATFORM
    end
  end

  describe '(tasks)' do
    before :each do
      Rake.application.clear
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

        it "should depend on 'compile:extension_one'" do
          Rake::Task['compile'].prerequisites.should include('compile:extension_one')
        end
      end

      describe 'compile:extension_one' do
        it 'should define as task' do
          Rake::Task.task_defined?('compile:extension_one').should be_true
        end

        it "should depend on 'lib/extension_one.{so,bundle}'" do
          Rake::Task['compile:extension_one'].prerequisites.should include("lib/#{@ext_bin}")
        end
      end

      describe 'lib/extension_one.{so,bundle}' do
        it 'should define as task' do
          Rake::Task.task_defined?("lib/#{@ext_bin}").should be_true
        end

        it "should depend on 'lib'" do
          Rake::Task["lib/#{@ext_bin}"].prerequisites.should include("lib")
        end

        it "should depend on 'tmp/extension_one.{so,bundle}'" do
          Rake::Task["lib/#{@ext_bin}"].prerequisites.should include("tmp/#{@platform}/extension_one/#{@ext_bin}")
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
        it "should include 'tmp' in the pattern" do
          CLEAN.should include('tmp')
        end
      end

      describe 'clobber' do
        it "should include 'lib/extension_one.{so,bundle}'" do
          CLOBBER.should include("lib/#{@ext_bin}")
        end
      end
    end

    describe '(native tasks)' do
      before :each do
        Rake::FileList.stub!(:[]).and_return(["ext/extension_one/source.c"])
        @spec = mock_gem_spec
        @ext_bin = ext_bin('extension_one')
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

        it 'should depend on gem specific native tasks' do
          Rake::ExtensionTask.new('extension_one', @spec)
          Rake::Task["native"].prerequisites.should include("native:my_gem")
        end

        describe 'native:my_gem' do
          it 'should depend on binary extension' do
            Rake::ExtensionTask.new('extension_one', @spec)
            Rake::Task["native:my_gem"].prerequisites.should include("lib/#{@ext_bin}")
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

end
