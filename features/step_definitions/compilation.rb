Given /^scaffold code for extension '(.*)'$/ do |extension_name|
  setup_scaffold
  setup_task_for extension_name
  setup_source_for extension_name
end

Given /^binary extension '(.*)' do exist in '(.*)'$/ do |extension_name, folder|
  setup_binaries_for extension_name, folder
end

Given /^intermediate files for extension '(.*)' do exist in '(.*)'$/ do |extension_name, folder|
  setup_intermediate_files_for extension_name, folder
end

When /^touching '(.*)' file of extension '(.*)'$/ do |file, extension_name|
  FileUtils.touch "ext/#{extension_name}/#{file}"
end

Then /^binary extension '(.*)' (must|must not) exist in '(.*)'$/ do |extension_name, condition, folder|
  ext_for_platform = File.join(folder, "#{extension_name}.#{RbConfig::CONFIG['DLEXT']}")
  if condition == 'must'
    File.exist?(ext_for_platform).should be_true
  else
    File.exist?(ext_for_platform).should be_false
  end
end

def setup_scaffold
  # create folder structure
  FileUtils.mkdir_p "lib"
  FileUtils.mkdir_p "tasks"
  FileUtils.mkdir_p "tmp"

  # create Rakefile loader
  File.open("Rakefile", 'w') do |rakefile|
    rakefile.puts template_rakefile.strip
  end
end

def setup_task_for(extension_name)
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

def setup_binaries_for(extension_name, folder)
  ext_for_platform = File.join(folder, "#{extension_name}.#{RbConfig::CONFIG['DLEXT']}")
  FileUtils.touch ext_for_platform
end

def setup_intermediate_files_for(extension_name, folder)
  setup_binaries_for(extension_name, folder)
  FileUtils.touch "#{folder}/Makefile"
  FileUtils.touch "#{folder}/source.#{RbConfig::CONFIG['OBJEXT']}"
end
