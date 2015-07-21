require File.dirname(__FILE__) + '/lib/rake/compiler/version'

Gem::Specification.new do |spec|
  spec.name          = "new"
  spec.version       = Rake::Compiler::VERSION
  spec.authors       = ["someone"]
  spec.email         = ["someone@example.com"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
end
