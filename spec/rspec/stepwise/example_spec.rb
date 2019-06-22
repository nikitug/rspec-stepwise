RSpec.describe 'User Scenarios' do
  class ClientApi
    def register(user)
    end

    def sign_in(user)
      Response.new
    end

    def logs
    end

    class Response
      def forbidden?
        true
      end

      def successful?
        true
      end
    end
  end

  class Mailbox
    def confirm(user)
    end

    def clear
    end
  end

  class User
  end

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
    end

    # This step will not be executed because previous one failed.
    step 'successfully sign in' do
      response = api.sign_in(user)
      expect(response).to be_successful
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
