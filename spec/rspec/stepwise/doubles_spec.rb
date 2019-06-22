RSpec.describe 'Doubles Usage' do
  it 'is expected to fail when using doubles in shared context' do
    result = run do
      stepwise do
        let(:api) { double(:api, call: nil) }

        step 'one' do
          api.call
        end

        step 'another' do
          api.call
        end
      end
    end
    expect(result).to be_falsey
  end
end
