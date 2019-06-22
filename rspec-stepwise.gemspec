require_relative "lib/rspec/stepwise/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-stepwise"
  spec.version       = RSpec::Stepwise::VERSION
  spec.authors       = ["Nikita Afanasenko"]
  spec.email         = ["nikita@afanasenko.name"]

  spec.summary       = "Stepwise execution for RSpec."
  spec.description   = "Stepwise execution for RSpec."
  spec.homepage      = "https://github.com/nikitug/rspec-stepwise"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
