# Naive way of looking into platforms, please include others like FreeBSD?
if RUBY_PLATFORM =~ /linux|darwin/
  Given %r{^I'm running a POSIX operating system$} do
  end
end

Given %r{^I've installed cross compile toolchain$} do
  compiler = 'i586-mingw32msvc-gcc'
  found = false
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    next unless File.exist?(File.join(path, compiler))
    found = true
  end
  raise "Cannot locate '#{compiler}' in the PATH." unless found
end

Then /^binaries for platform '(.*)' get generated$/ do |platform|
  ext_for_platform = Dir.glob("tmp/#{platform}/**/*.#{RbConfig::CONFIG['DLEXT']}")
  ext_for_platform.should_not be_empty
end
