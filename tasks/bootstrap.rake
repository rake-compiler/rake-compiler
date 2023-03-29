desc 'Ensure all the cross compiled versions are installed'
task :bootstrap do
  raise 'Sorry, this only works on OSX and Linux' if /mswin|mingw/.match?(RUBY_PLATFORM)

  versions = %w[1.8.7-p371 1.9.3-p392 2.0.0-p0]

  versions.each do |version|
    puts "[INFO] Attempt to cross-compile Ruby #{version}"
    ruby "-Ilib bin/rake-compiler cross-ruby VERSION=#{version}"
  end
end
