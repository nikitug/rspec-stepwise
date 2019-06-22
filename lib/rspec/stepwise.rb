require 'rspec/stepwise/version'

module RSpec
  # Provides DSL for defining a series of steps.
  #
  # @example
  #   RSpec.describe 'user registration and sign in' do
  #     stepwise do
  #       step 'register' do
  #         api.register(user)
  #         mailbox.confirm(user)
  #       end
  #
  #       step 'sign in' do
  #         token = api.sign_in(user)
  #         expect(token).not_to be expired
  #       end
  #     end
  #   end
  #
  module Stepwise
    # Defines new series of steps. Supports the same arguments as `RSpec.describe`.
    # @see RSpec.describe
    def stepwise(name = nil, *args, &block)
      if args.last.is_a?(Hash)
        args.last[:order] = :defined
      else
        args << { order: :defined }
      end
      describe(name, *args) do
        Builder.new(self).instance_eval(&block)
      end
    end

    # Provides DSL for steps definition and builds execution context.
    class Builder
      # @param klass [RSpec::Core::ExampleGroup]
      def initialize(klass)
        @klass = klass
        @steps_context = Context.new(klass)
        @fail_callbacks = []
      end

      # Defines new step in a series. Supports the same arguments as `RSpec::Core::ExampleGroup.it`.
      # @see RSpec::Core::ExampleGroup.it
      def step(*args, &block)
        # `it` defines method within `klass`, so Builder's
        # instance variable will not be visible there,
        # so we use local var.
        steps_context = @steps_context
        fail_callbacks = @fail_callbacks
        @klass.it(*args) do
          if steps_context.previous_failed?
            pending 'Previous step failed'
            fail
          else
            begin
              steps_context.run_step(&block)
            rescue
              fail_callbacks.each do |callback|
                steps_context.run(&callback)
              end
              raise
            end
          end
        end
      end

      # Runs if any step failed. Can be executed multiple times.
      # Execution will happen in the same order as definition order.
      #
      # @example
      #   # Outputs API logs in case of failure.
      #   on_fail do
      #     puts api.execution_logs
      #   end
      #
      def on_fail(&block)
        @fail_callbacks << block
      end

      # Runs after all steps finished.
      #
      # @example
      #   # Clears virtual mailbox after all steps.
      #   after do
      #     mailbox.clear
      #   end
      #
      def after(&block)
        steps_context = @steps_context
        @klass.after(:all) do
          steps_context.run(&block)
        end
      end

      private

      def method_missing(name, *args, &block)
        if @klass.respond_to?(name)
          @klass.public_send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @klass.respond_to?(name, include_private) || super
      end
    end

    # @api private
    class Context
      def initialize(klass)
        @context = klass.new
        @previous_failed = false
      end

      def run_step(&block)
        run(&block)
      rescue
        @previous_failed = true
        raise
      end

      def run(&block)
        @context.instance_eval(&block)
      end

      def previous_failed?
        @previous_failed
      end
    end
  end
end
