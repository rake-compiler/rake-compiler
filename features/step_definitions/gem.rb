Given /^a gem named '(.*)'$/ do |gem_name|
  generate_gem_task gem_name
end

Then /^(ruby|binary) gem for '(.*)' version '(.*)' do exist in '(.*)'$/ do |type, gem_name, version, folder|
  if type == 'ruby' then
    gem_file = "#{folder}/#{gem_name}-#{version}.gem"
  else
    platform = Gem::Platform.local.to_s
    gem_file = "#{folder}/#{gem_name}-#{version}-#{platform}.gem"
  end
  File.exist?(gem_file).should be_true
end
