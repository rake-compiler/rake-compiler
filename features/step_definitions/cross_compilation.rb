# Naive way of looking into platforms, please include others like FreeBSD?
if RUBY_PLATFORM =~ /linux|darwin/
  Given %r{^I'm running a POSIX operating system$} do
  end
end

Given %r{^I've cross compile tools installed$} do
  compiler = 'i586-mingw32msvc-gcc'
  found = false
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    next unless File.exist?(File.join(path, compiler))
    found = true
  end
  raise "Cannot locate '#{compiler}' in the PATH." unless found
end
