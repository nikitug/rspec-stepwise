# RSpec Stepwise Executor

Provides a simple DSL on top of RSpec for defining a series of spec execution steps. Particularly useful for describing of human-readable integration testing scenarios.

RSpec Stepwise provides the following guarantees within the same steps group:

- Strict step execution order, even if RSpec is configured to run examples randomly.
- All steps share the same execution context, thus share instances defined in `let` etc.
- All steps after the failed one will be skipped.

## Usage

Configure RSpec to use stepwise DSL:

```ruby
require 'rspec/stepwise'

RSpec.configure do |config|
  config.extend RSpec::Stepwise
  # ...
end
```

This adds `stepwise` method for creating ordered example groups and `step` method for describing particular step in a chain. See full usage example:

```ruby
RSpec.describe 'User Scenarios' do
  # Defines example group for account confirmation scenario.
  # All steps within this group will run in an order.
  stepwise 'Account Confirmation' do
    # All RSpec APIs works as usual inside both group and steps.
    let(:api) { ClientApi.new }
    let(:mailbox) { Mailbox.new }
    let(:user) { User.new }

    step 'register' do
      api.register(user)
    end

    step 'unable to sign in' do
      response = api.sign_in(user)
      expect(response).to be_forbidden
    end

    step 'confirm' do
      mailbox.confirm(user)
      fail 'Email not found in mailbox'
    end

    # This step will not be executed because previous one failed.
    step 'successfully sign in' do
      response = api.sign_in(user)
      expect(response).to be_successfull
    end

    # Called after all steps, even if one failed.
    after do
      mailbox.clear
    end

    # Called only when a step failed.
    on_fail do
      puts api.logs
    end
  end
end
```

## Known Limitations

RSpec doubles should not be used in a shared stepwise context, otherwise it leads to:

_#<Double ...> was originally created in one example but has leaked into another example and can no longer be used. rspec-mocks' doubles are designed to only last for one example, and you need to create a new one in each example you wish to use it for._

So this will not work:

```ruby
stepwise do
  let(:api) { double(:api, call: nil) }

  step 'one' do
    api.call
  end

  step 'another' do
    api.call
  end
end
```

Instead you have to do something like:

```ruby
stepwise do
  step 'one' do
    api = double(:api, call: nil)
    api.call
  end

  step 'another' do
    api = double(:api, call: nil)
    api.call
  end
end
```

## Installation

Using Bundler:

```ruby
gem 'rspec-stepwise', '~> 0.1.0'
```

Or using rubygems:

```bash
gem install rspec-stepwise
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nikitug/rspec-stepwise.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
