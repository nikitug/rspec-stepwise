require 'bundler/setup'
require 'rspec/stepwise'

RSpec.configure do |config|
  config.extend RSpec::Stepwise
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  module Runner
    def run(&block)
      result = RSpec.describe(&block).run
      RSpec.clear_examples
      result
    end
  end
  config.include Runner

  config.order = :random
  Kernel.srand config.seed
end
