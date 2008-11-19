Given /^a extension named '(.*)'$/ do |extension_name|
  generate_extension_task_for extension_name
  generate_source_code_for extension_name
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
