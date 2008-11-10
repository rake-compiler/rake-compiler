Given /^a extension named '(.*)'$/ do |extension_name|
  setup_extension_scaffold
  setup_extension_task_for extension_name
  setup_source_for extension_name
end

Given /^not changed any file since$/ do
  # don't do anything, that's the purpose of this step!
end

When /^touching '(.*)' file of extension '(.*)'$/ do |file, extension_name|
  Kernel.sleep 1
  FileUtils.touch "ext/#{extension_name}/#{file}"
end

Then /^binary extension '(.*)' (do|do not) exist in '(.*)'$/ do |extension_name, condition, folder|
  ext_for_platform = File.join(folder, "#{extension_name}.#{RbConfig::CONFIG['DLEXT']}")
  if condition == 'do'
    File.exist?(ext_for_platform).should be_true
  else
    File.exist?(ext_for_platform).should be_false
  end
end

def setup_extension_scaffold
  # create folder structure
  FileUtils.mkdir_p "lib"
  FileUtils.mkdir_p "tasks"
  FileUtils.mkdir_p "tmp"

  # create Rakefile loader
  File.open("Rakefile", 'w') do |rakefile|
    rakefile.puts template_rakefile.strip
  end
end

def setup_extension_task_for(extension_name)
  # create folder structure
  FileUtils.mkdir_p "ext/#{extension_name}"

  # create specific extension rakefile
  File.open("tasks/#{extension_name}.rake", 'w') do |ext_rake|
    ext_rake.puts template_rake_extension(extension_name)
  end
end

def setup_source_for(extension_name)
  # source C file
  File.open("ext/#{extension_name}/source.c", 'w') do |c|
    c.puts template_source_c(extension_name)
  end

  # header H file
  File.open("ext/#{extension_name}/source.h", 'w') do |h|
    h.puts template_source_h
  end

  # extconf.rb file
  File.open("ext/#{extension_name}/extconf.rb", 'w') do |ext|
    ext.puts template_extconf(extension_name)
  end
end
